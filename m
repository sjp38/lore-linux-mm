Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 641E76B00C4
	for <linux-mm@kvack.org>; Sun,  1 Jul 2012 09:26:34 -0400 (EDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Sun, 1 Jul 2012 07:26:32 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q61DQIhx271672
	for <linux-mm@kvack.org>; Sun, 1 Jul 2012 07:26:18 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q61DQH8K017917
	for <linux-mm@kvack.org>; Sun, 1 Jul 2012 07:26:17 -0600
Date: Sun, 1 Jul 2012 21:26:14 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2/3] mm/sparse: fix possible memory leak
Message-ID: <20120701132614.GA12917@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1340814968-2948-1-git-send-email-shangw@linux.vnet.ibm.com>
 <1340814968-2948-2-git-send-email-shangw@linux.vnet.ibm.com>
 <4FEB3C67.6070604@linux.vnet.ibm.com>
 <20120628060330.GA26576@shangw>
 <4FEC700A.6090205@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FEC700A.6090205@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm@kvack.org, mhocko@suse.cz, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org

On Thu, Jun 28, 2012 at 07:54:02AM -0700, Dave Hansen wrote:
>On 06/27/2012 11:03 PM, Gavin Shan wrote:
>>> >Gavin, have you actually tested this in some way?  It looks OK to me,
>>> >but I worry that you've just added a block of code that's exceedingly
>>> >unlikely to get run.
>> I didn't test this and I just catch the point while reading the source
>> code. By the way, I would like to know the popular utilities used for
>> memory testing. If you can share some information regarding that, that
>> would be great.
>> 
>> 	- memory related benchmark testing utility.
>> 	- some documents on Linux memory testing.
>
>This patch is intended to fix a memory leak in the case of a race.  Can
>you _actually_ make it race to ensure that things work properly?  If
>not, can you add something like a sleep() to _force_ it to race?
>

Thank you very much, Dave :-)

>Or, have you simply run your code a couple of times like this, both for
>the bootmem and slab cases:
>
>	int nid = 0;
>	for (i=0; i < something; i++) {
>		section = sparse_index_alloc(nid);
>		sparse_index_free(section, nid);
>	}
>

I ran following function for bootmem/slab case and everything looks fine. Please
let me know if you have any more concerns :-)

void sparse_test(void)
{
        int nid;
        int i;
        struct mem_section *section;

        pr_info("*************************************\n");
        if (slab_is_available()) {
                pr_info("* Sparse Testing on slab\n");
        } else {
                pr_info("* Sparse Testing on bootmem\n");
        }
        pr_info("*************************************\n");

	/* Currently, we have 2 nodes in the system */
        for (nid = 0; nid < 2; nid++) {
                for (i = 0; i < 100; i++) {
                        pr_info(" Testing sequence ... %d for nid %d\n", i, nid);
                        section = sparse_index_alloc(nid);
                        sparse_index_free(section, nid);
                }
        }
}

Thanks,
Gavin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
