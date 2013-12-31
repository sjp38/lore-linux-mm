Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id D1C436B0031
	for <linux-mm@kvack.org>; Tue, 31 Dec 2013 05:59:51 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id fa1so12583134pad.31
        for <linux-mm@kvack.org>; Tue, 31 Dec 2013 02:59:51 -0800 (PST)
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com. [202.81.31.146])
        by mx.google.com with ESMTPS id s7si31707729pae.330.2013.12.31.02.59.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 31 Dec 2013 02:59:50 -0800 (PST)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Tue, 31 Dec 2013 20:59:46 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 67DCE3578053
	for <linux-mm@kvack.org>; Tue, 31 Dec 2013 21:59:43 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBVAeuYq32440414
	for <linux-mm@kvack.org>; Tue, 31 Dec 2013 21:40:58 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBVAxfXG028075
	for <linux-mm@kvack.org>; Tue, 31 Dec 2013 21:59:41 +1100
Message-ID: <52C2A564.4040809@linux.vnet.ibm.com>
Date: Tue, 31 Dec 2013 16:37:16 +0530
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] mm readahead: Fix the readahead fail in case of empty
 numa node
References: <1386066977-17368-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <20131203143841.11b71e387dc1db3a8ab0974c@linux-foundation.org> <529EE811.5050306@linux.vnet.ibm.com> <20131204004125.a06f7dfc.akpm@linux-foundation.org> <529EF0FB.2050808@linux.vnet.ibm.com> <20131204134838.a048880a1db9e9acd14a39e4@linux-foundation.org> <20131211224917.GF1163@quack.suse.cz> <20131211150522.4b853323e8b82f342f81b64d@linux-foundation.org> <CA+55aFy-e-uok1K9mSNTYS4bJJfHkxXofY7T1UVWgHOyXuE84A@mail.gmail.com>
In-Reply-To: <CA+55aFy-e-uok1K9mSNTYS4bJJfHkxXofY7T1UVWgHOyXuE84A@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 12/14/2013 06:09 AM, Linus Torvalds wrote:
> On Wed, Dec 11, 2013 at 3:05 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
>>
>> But I'm really struggling to think up an implementation!  The current
>> code looks only at the caller's node and doesn't seem to make much
>> sense.  Should we look at all nodes?  Hard to say without prior
>> knowledge of where those pages will be coming from.
>
> I really think we want to put an upper bound on the read-ahead, and
> I'm not convinced we need to try to be excessively clever about it. We
> also probably don't want to make it too expensive to calculate,
> because afaik this ends up being called for each file we open when we
> don't have pages in the page cache yet.
>
> The current function seems reasonable on a single-node system. Let's
> not kill it entirely just because it has some odd corner-case on
> multi-node systems.
>
> In fact, for all I care, I think it would be perfectly ok to just use
> a truly stupid hard limit ("you can't read-ahead more than 16MB" or
> whatever).
>
> What we do *not* want to allow is to have people call "readahead"
> functions and basically kill the machine because you now have a
> unkillable IO that is insanely big. So I'd much rather limit it too
> much than too little. And on absolutely no sane IO susbsystem does it
> make sense to read ahead insane amounts.
>
> So I'd rather limit it to something stupid and small, than to not
> limit things at all.
>
> Looking at the interface, for example, the natural thing to do for the
> "readahead()" system call, for example, is to just give it a size of
> ~0ul, and let the system limit things, becaue limiting things in useer
> space is just not reasonable.
>
> So I really do *not* think it's fine to just remove the limit entirely.
>

Very sorry for late reply (was on very loong vacation).

How about having 16MB limit only for remote readaheads and continuing
the rest as is, something like below:

#define MAX_REMOTE_READAHEAD    4096UL

unsigned long max_sane_readahead(unsigned long nr)
{

	unsigned long local_free_page = (node_page_state(numa_node_id(), 
NR_INACTIVE_FILE)
	+ node_page_state(numa_node_id(), NR_FREE_PAGES));
	unsigned long sane_nr = min(nr, MAX_REMOTE_READAHEAD);

	return (local_free_page ? min(nr, local_free_page / 2) : sane_nr);
}

or we can enforce 16MB limit for all the case too.

I 'll send a patch accordingly.

(readahead max will scale accordingly if we dont have 4k page size
  above).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
