Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 817FE6B0038
	for <linux-mm@kvack.org>; Thu,  4 May 2017 12:50:00 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id q71so6757940qkl.2
        for <linux-mm@kvack.org>; Thu, 04 May 2017 09:50:00 -0700 (PDT)
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com. [209.85.220.172])
        by mx.google.com with ESMTPS id t195si2227995qke.27.2017.05.04.09.49.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 May 2017 09:49:59 -0700 (PDT)
Received: by mail-qk0-f172.google.com with SMTP id n4so15979431qkc.0
        for <linux-mm@kvack.org>; Thu, 04 May 2017 09:49:59 -0700 (PDT)
Subject: Re: RFC v2: post-init-read-only protection for data allocated
 dynamically
References: <9200d87d-33b6-2c70-0095-e974a30639fd@huawei.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <a445774f-a307-25aa-d44e-c523a7a42da6@redhat.com>
Date: Thu, 4 May 2017 09:49:55 -0700
MIME-Version: 1.0
In-Reply-To: <9200d87d-33b6-2c70-0095-e974a30639fd@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

[adding kernel-hardening since I think there would be interest]

On 05/03/2017 05:06 AM, Igor Stoppa wrote:
> Hello,
> 
> please review my (longish) line of thoughts, below.
> 
> I've restructured them so that they should be easier to follow.
> 
> 
> Observations
> ------------
> 
> * it is currently possible, by using prefix "__read_only", to have the
> linker place a static variable into a special memory region, which will
> become write-protected at the end of the init phase.
> 
> * the purpose is to write-protect data which is not expected to change,
> ever, after it has been initialized.
> 
> * The mechanism used for locking down the memory region is to program
> the MMU to trap writes to said region. It is fairly efficient and
> HW-backed, so it doesn't introduce any major overhead, but the MMU deals
> only with pages or supersets of pages, hence the need to collect all the
> soon-to-be-read-only data - and only that - into the "special region".
> The "__read_only" modifier is the admission ticket.
> 
> * the write-protecting feature helps supporting memory integrity in
> general and can also help spotting rogue writes, whatever their origin
> might be: uninitialized or expired pointers, wrong pointer arithmetic, etc.
> 
> 
> 
> Problem
> -------
> 
> The feature is available only for *static* data - it will not work with
> something like a linked list that is put together during init, for example.
> 
> 
> 
> Wish
> ----
> 
> My starting point are the policy DB of SE Linux and the LSM Hooks, but
> eventually I would like to extend the protection also to other
> subsystems, in a way that can be merged into mainline.
> 
> 
> 
> Analysis
> --------
> 
> * the solution I come up with has to be as little invasive as possible,
> at least for what concerns the various subsystems whose integrity I want
> to enhance.
> 
> * In most, if not all, the cases that could be enhanced, the code will
> be calling kmalloc/vmalloc, indicating GFP_KERNEL as the desired type of
> memory.
> 
> * I suspect/hope that the various maintainer won't object too much if my
> changes are limited to replacing GFP_KERNEL with some other macro, for
> example what I previously called GFP_LOCKABLE, provided I can ensure that:
> 
>   -1) no penalty is introduced, at least when the extra protection
>       feature is not enabled, iow nobody has to suffer from my changes.
>       This means that GFP_LOCKABLE should fall back to GFP_KERNEL, when
>       it's not enabled.
> 
>   -2) when the extra protection feature is enabled, the code still
>       works as expected, as long as the data identified for this
>       enhancement is really unmodified after init.
> 
> * In my quest for improved memory integrity, I will deal with very
> different memory size being allocated, so if I start writing my own
> memory allocator, starting from a page-aligned chunk of normal memory,
> at best I will end up with a replica of kmalloc, at worst with something
> buggy. Either way, it will be extremely harder to push other subsystems
> to use it.
> I probably wouldn't like it either, if I was a maintainer.
> 
> * While I do not strictly need a new memory zone, memory zones are what
> kmalloc understands at the moment: AFAIK, it is not possible to tell
> kmalloc from which memory pool it should fish out the memory, other than
> having a reference to a memory zone.
> If it was possible to aim kmalloc at arbitrary memory pools, probably we
> would not be having this exchange right now. And probably there would
> not be so many other folks trying to have their memory zone of interest
> being merged. However I suspect this solution would be sub-optimal for
> the normal use cases, because there would be the extra overhead of
> passing the reference to the memory pool, instead of encoding it into
> bitfields, together with other information.
> 
> * there are very slim chances (to be optimistic :) that I can get away
> with having my custom zone merged, because others are trying with
> similar proposals and they get rejected, so maybe I can have better luck
> if I propose something that can also work for others.
> 
> * currently memory zones are mapped 1:1 to bits in crowded a bitmask,
> but not all these zones are really needed in a typical real system, some
> are kept for backward compatibility and supporting distros, which cannot
> know upfront the quirks of the HW they will be running on.
> 
> 
> Conclusions
> -----------
> 
> * the solution that seems to be more likely to succeed is to remove the
> 1:1 mapping between optional zones and their respective bits.
> 
> * the bits previously assigned to the optional zones would become
> available for mapping whatever zone a system integrator wants to support.
> 
> 
> Cons:
> There would be still a hard constraint on the maximum number of zones
> available simultaneously, so one will have to choose which of the
> optional zones to enable, and be ready to deal with own zone
> disappearing (ex: fall back to normal memory and give up some/all
> functionality)
> 
> Pros:
> * No bit would go to waste: those who want to have own custom zone could
> make a better use of the allocated-but-not-necessary-to-them bits.
> * There would be a standard way for people to add non-standard zones.
> * It doesn't alter the hot paths that are critical to efficient memory
> handling.
> 
> So it seems a win-win scenario, apart from the fact that I will probably
> have to reshuffle a certain amount of macros :-)
> 
> 
> P.S.
> There was an early advice of creating and using a custom-made memory
> allocator, I hope it's now clear why I don't think it's viable: it might
> work if I use it only for further code that I will write, but it really
> doesn't seem the best way to convince other subsystem maintainers to
> take in my changes, if I suggest them to give up the super optimized
> kmalloc (and friends) in favor of some homebrew allocator I wrote :-/
> 
> 

BPF takes the approach of calling set_memory_ro to mark regions as
read only. I'm certainly over simplifying but it sounds like this
is mostly a mechanism to have this happen mostly automatically.
Can you provide any more details about tradeoffs of the two approaches?

arm and arm64 have the added complexity of using larger
page sizes on the linear map so dynamic mapping/unmapping generally
doesn't work. arm64 supports DEBUG_PAGEALLOC by mapping with only
pages but this is generally only wanted as a debug mechanism.
I don't know if you've given this any thought at all.

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
