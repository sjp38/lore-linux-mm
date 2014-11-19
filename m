Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 999BB6B007B
	for <linux-mm@kvack.org>; Wed, 19 Nov 2014 18:10:32 -0500 (EST)
Received: by mail-wi0-f176.google.com with SMTP id ex7so6942648wid.3
        for <linux-mm@kvack.org>; Wed, 19 Nov 2014 15:10:32 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ce6si4641875wib.72.2014.11.19.15.10.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Nov 2014 15:10:31 -0800 (PST)
Received: from relay2.suse.de (charybdis-ext.suse.de [195.135.220.254])
	by mx2.suse.de (Postfix) with ESMTP id 2645CAAF1
	for <linux-mm@kvack.org>; Wed, 19 Nov 2014 23:10:31 +0000 (UTC)
Message-ID: <546D2366.1050506@suse.cz>
Date: Thu, 20 Nov 2014 00:10:30 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: isolate_freepages_block and excessive CPU usage by OSD process
References: <20141119012110.GA2608@cucumber.iinet.net.au> <CABYiri99WAj+6hfTq+6x+_w0=VNgBua8N9+mOvU6o5bynukPLQ@mail.gmail.com> <20141119212013.GA18318@cucumber.anchor.net.au>
In-Reply-To: <20141119212013.GA18318@cucumber.anchor.net.au>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

On 11/19/2014 10:20 PM, Christian Marie wrote:
> On Wed, Nov 19, 2014 at 10:03:44PM +0400, Andrey Korolyov wrote:
>> > We are using Mellanox ipoib drivers which do not do scatter-gather, so I'm
>> > currently working on adding support for that (the hardware supports it). Are
>> > you also using ipoib or have something else doing high order allocations? It's
>> > a bit concerning for me if you don't as it would suggest that cutting down on
>> > those allocations won't help.
>> 
>> So do I. On a test environment with regular tengig cards I was unable to
>> reproduce the issue. Honestly, I thought that almost every contemporary
>> driver for high-speed cards is working with scatter-gather, so I had not mlx
>> in mind as a potential cause of this problem from very beginning.
> 
> Right, the drivers handle SG just fine, even in UD mode. It's just that as soon
> as you go switch to CM they turn of hardware IP csums and SG support. The only
> question I remain to answer before testing a patched driver is whether or not
> the messages sent by Ceph are fragmented enough to save allocations. If not, we
> could always patch Ceph as well but this is beginning to snowball.
> 
> Here is the untested WIP patch for SG support in ipoib CM mode, I'm currently
> talking to the original author of a larger patch to review and split that and
> get them both upstream.:
> 
> https://gist.github.com/christian-marie/e8048b9c118bd3925957
> 
>> There are a couple of reports in ceph lists, complaining for OSD
>> flapping/unresponsiveness without clear reason on certain (not always clear
>> though) conditions which may have same root cause.
> 
> Possibly, though ipoib and Ceph seem to be a relatively rare combination.
> Someone will likely find this thread if it is the same root cause.
> 
>> Wonder if numad-like mechanism will help there, but its usage is generally an
>> anti-performance pattern in my experience.
> 
> We've played with zone_reclaim_mode and numad to no avail. Only thing we haven't
> tried is striping, which I don't want to do anyway.
> 
> If these large allocations are indeed a reasonable thing to ask of the
> compaction/reclaim subsystem that seems like the best way forward. I have two
> questions that follow from this conjecture:
> 
> Are compaction behaving badly or are we just asking for too many high order
> allocations?
> 
> Is this fixed in a later kernel? I haven't tested yet.

As I said, recent kernels received many compaction performance tuning patches,
and reclaim as well. I would recommend trying them, if it's possible.

You mention 3.10.0-123.9.3.el7.x86_64 which I have no idea how it relates to
upstream stable kernel. Upstream version 3.10.44 received several compaction
fixes that I'd deem critical for compaction to work as intended, and lack of
them could explain your problems:

mm: compaction: reset cached scanner pfn's before reading them
commit d3132e4b83e6bd383c74d716f7281d7c3136089c upstream.

mm: compaction: detect when scanners meet in isolate_freepages
commit 7ed695e069c3cbea5e1fd08f84a04536da91f584 upstream.

mm/compaction: make isolate_freepages start at pageblock boundary
commit 49e068f0b73dd042c186ffa9b420a9943e90389a upstream.

You might want to check if those are included in your kernel package, and/or try
upstream stable 3.10 (if you can't use the latest for some reason).

Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
