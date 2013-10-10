Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id D0DB26B0031
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 06:38:49 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so2366219pbb.14
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 03:38:49 -0700 (PDT)
Received: by mail-vb0-f46.google.com with SMTP id p13so1417814vbe.5
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 03:38:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20131009115243.GA1198@thunk.org>
References: <20130926141428.392345308@kernel.org>
	<20130926161401.GA3288@medulla.variantweb.net>
	<20131009115243.GA1198@thunk.org>
Date: Thu, 10 Oct 2013 18:38:46 +0800
Message-ID: <CAA_GA1e79Uzj87hvN1fg9sp+u9BG2_UBwFy1EqU26WsPDeywWg@mail.gmail.com>
Subject: Re: [RFC 0/4] cleancache: SSD backed cleancache backend
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Shaohua Li <shli@kernel.org>, Linux-MM <linux-mm@kvack.org>, Bob Liu <bob.liu@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>

On Wed, Oct 9, 2013 at 7:52 PM, Theodore Ts'o <tytso@mit.edu> wrote:
> On Thu, Sep 26, 2013 at 11:14:01AM -0500, Seth Jennings wrote:
>>
>> I can see this burning out your SSD as well.  If someone enabled this on
>> a machine that did large (relative to the size of the SDD) streaming
>> reads, you'd be writing to the SSD continuously and never have a cache
>> hit.
>
> If we are to do page-level caching, we really need to change the VM to
> use something like IBM's Adaptive Replacement Cache[1], which allows
> us to track which pages have been more frequently used, so that we
> only cache those pages, as opposed to those that land in the cache
> once and then aren't used again.  (Consider what might happen if you
> are using clean cache and then the user does a full backup of the
> system.)

One way I used in zcache is adding a WasActive flag to page flags.
Only cache pages which are shrinked from active file lru list.

>
> [1] http://en.wikipedia.org/wiki/Adaptive_replacement_cache
>
> This is how ZFS does SSD caching; the basic idea is to only consider
> for cacheing those pages which have been promoted into its Frequenly
> Refrenced list, and then have been subsequently aged out.  At that
> point, the benefit we would have over a dm-cache solution is that we
> would be taking advantage of the usage information tracked by the VM
> to better decide what is cached on the SSD.
>
> So something to think about,
>

-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
