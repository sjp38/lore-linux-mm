Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 628C66B0005
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 23:08:38 -0500 (EST)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 6 Mar 2013 13:58:48 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id A717F2BB0023
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 15:08:31 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r263ttRU66256934
	for <linux-mm@kvack.org>; Wed, 6 Mar 2013 14:55:55 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2648UIp016993
	for <linux-mm@kvack.org>; Wed, 6 Mar 2013 15:08:31 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V1 06/24] powerpc: Reduce PTE table memory wastage
In-Reply-To: <20130305021219.GC2888@iris.ozlabs.ibm.com>
References: <1361865914-13911-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1361865914-13911-7-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20130304045853.GB27523@drongo> <874ngr2zz1.fsf@linux.vnet.ibm.com> <20130305021219.GC2888@iris.ozlabs.ibm.com>
Date: Wed, 06 Mar 2013 09:38:27 +0530
Message-ID: <87fw09891g.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mackerras <paulus@samba.org>
Cc: benh@kernel.crashing.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Paul Mackerras <paulus@samba.org> writes:

> On Mon, Mar 04, 2013 at 04:28:42PM +0530, Aneesh Kumar K.V wrote:
>> Paul Mackerras <paulus@samba.org> writes:
>> 
>> > The other general comment I have is that it's not really clear when a
>> > page will be on the mm->context.pgtable_list and when it won't.  I
>> > would like to see an invariant that says something like "the page is
>> > on the pgtable_list if and only if (page->_mapcount & FRAG_MASK) is
>> > neither 0 nor FRAG_MASK".  But that doesn't seem to be the case
>> > exactly, and I can't see any consistent rule, which makes me think
>> > there are going to be bugs in corner cases.
>> >
>> 
>> 
>> I added the below comment when initializing the list.
>> 
>> +#ifdef CONFIG_PPC_64K_PAGES
>> +       /*
>> +        * Used to support 4K PTE fragment. The pages are added to list,
>> +        * when we have free framents in the page. We track the whether
>> +        * a page frament is available using page._mapcount. A value of
>> +        * zero indicate none of the fragments are used and page can be
>> +        * freed. A value of FRAG_MASK indicate all the fragments are used
>> +        * and hence the page will be removed from the below list.
>> +        */
>> +       INIT_LIST_HEAD(&init_mm.context.pgtable_list);
>> +#endif
>> 
>> I am not sure about why you say there is no consistent rule. Can you
>> elaborate on that ?
>
> Well, sometimes you take things off the list when mask == 0, and
> sometimes when (mask & FRAG_MASK) == 0.  So it's not clear whether the
> page is supposed to be on the list when (mask & FRAG_MASK) == 0 but
> mask != 0.  If you stated in a comment what the rule was supposed to
> be then reviewers could check whether your code implemented that rule.
> Also, if you had a consistent rule you could more easily add debug
> code to check that the rule was being followed.


I guess you are looking at this in page_table_free_rcu ?

+	mask = atomic_xor_bits(&page->_mapcount, bit | (bit << FRAG_MASK_BITS));
+	if (!(mask & FRAG_MASK))
+		list_del(&page->lru);
+	else {

We want to remove the page from list looking at the lower half bits. If
all the bits are cleared, that indicate nobody is using that page. But
then we may have pending rcu, which is indicated by higher half. So if
the lower half is 0 we can remove from the list. _mapcount is 0 we can
free the page. 

Now if all the bits in the lower half is set then also we remove the
page from the list, because we don't have any free fragments in the
page.


>
> Also, that comment above doesn't say anything about the upper bits and
> whether they have any influence on whether the page should be on the
> list or not.


will add more to the comment.

>
>> > Consider, for example, the case where a page has two fragments still
>> > in use, and one of them gets queued up by RCU for freeing via a call
>> > to page_table_free_rcu, and then the other one gets freed through
>> > page_table_free().  Neither the call to page_table_free_rcu nor the
>> > call to page_table_free will take the page off the list AFAICS, and
>> > then __page_table_free_rcu() will free the page while it's still on
>> > the pgtable_list.
>> 
>> The last one that ends up doing atomic_xor_bits which cause the mapcount
>> to go zero, will take the page off the list and free the page. 
>
> No, look at the example again.  page_table_free_rcu() won't take it
> off the list because it uses the (mask & FRAG_MASK) == 0 test, which
> fails (one fragment is still in use).  page_table_free() won't take it
> off the list because it uses the mask == 0 test, which also fails (one
> fragment is still waiting for the RCU grace period).  Finally,
> __page_table_free_rcu() doesn't take it off the list, it just frees
> the page.  Oops. :)

Got it, I will see how we can fix that.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
