Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18BEAC04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 23:33:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AD76020B1F
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 23:33:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="tXXK5Wkv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD76020B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4530F6B027F; Tue, 28 May 2019 19:33:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 403C96B0282; Tue, 28 May 2019 19:33:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A55E6B0287; Tue, 28 May 2019 19:33:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0056F6B027F
	for <linux-mm@kvack.org>; Tue, 28 May 2019 19:33:46 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id z11so253763otk.7
        for <linux-mm@kvack.org>; Tue, 28 May 2019 16:33:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=qZEaRDIPmwP5TWUCR9S3u/yLXWO2OSFxoldkS0AmjG0=;
        b=PbJnrV0ucN7Fmq9Q/n2GNMsPfyox+mk+YTtg1ffz4Hv7tX+mewrck0n/MhCTXlcxKf
         mW/d3iMeAp7GagzvIdLnyQUFofxQyPVTSgHxy9gGkn71l3U6n6L2fFZl+BUOxp2tR4FT
         haxlaZ+U3QF8GLNzC1alG3ZzyWM1IKbcVBjiFcVt00o37unew/RnZ9+7gnTjwiS0Tn5L
         evRueM97Rb0ewT/rlJBbtnq9iboQ5I38om4+TEZA5TNEOL+Ins5PcDLD0lDaJFQb5l7b
         ENW7HGSpVrv4jPBZEWEfSzerAOiFR6VIkczRukP3XwvSpFlXTfOrEFKkHt4p1+yg0486
         G+Tg==
X-Gm-Message-State: APjAAAWTvHRqXNJlLxTnSse7kRYsH/NREfRsu/HLQpL04JPgB3ojSKEL
	oOsQGP/tHcflIrFCe8oWT7C0lUJUX2TplVzS9xsVUIeUr3/PGUR4itkVSitF7iqLCJknitZGRDq
	FVOWF+hRjGGu/QP9m0EMw38mPZgM+jpbWX9xbwC+jq7zm3d1HVzpWzuuruaw65Nl7/Q==
X-Received: by 2002:a9d:69d9:: with SMTP id v25mr95700oto.4.1559086426595;
        Tue, 28 May 2019 16:33:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxzXtbs6FbSTWduDt0rhahHkijkVAp0xfxVyfJsDVj9s6HOc/bJIw4nOZUa00ilN2sEniHN
X-Received: by 2002:a9d:69d9:: with SMTP id v25mr95612oto.4.1559086424998;
        Tue, 28 May 2019 16:33:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559086424; cv=none;
        d=google.com; s=arc-20160816;
        b=xbXoprl9bMD4DLl8krBkmN0HIzzkt/KYldmv+KXw7UjmEnlOmjhyM9x60N7KxPPive
         Io68zo4RHQEW9Sn98upZFbmNmeQbiYMbo1p0ojQqc5j328oc6HAl/RNvy1zHEux5xN2o
         I4EyqhDMxzABVwusqpaMILaSB+nn7KV0fpSfkz5CkdRHVroIELkk0p6FmiAHIL1c5Sxx
         D5JoaCwtctg9tJG28glPVZd5JOCTVkCNgzFsYB49Q+n7aKs4DomJTX2glKwgBMaDRY/P
         CXXNIuTC1OA8BL7PJsmR73I6u5Ywro626aHzp9RszBnWfvUFaLoatQBZmFio271ibB5V
         ymbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=qZEaRDIPmwP5TWUCR9S3u/yLXWO2OSFxoldkS0AmjG0=;
        b=WNk7lP8XRK8bbs8mdKL1SfxnDxjYYBUS+CqY6LgGL0oNlyiAMrzkluAtPYUMC0p7yJ
         pVQFHl8djJSyE3f64JynzhZR352q/UK3tdqkiBZ6XB0Gla89V7MaNccbRVKYE9A7+hRB
         spZ1EIQ6sdyyke4dp5wghWbdz0ZifTOs1oUZscq5xrvWB7IG1su/tp+5Tli5fGXeiMJw
         8B1I8nhvrauZBwHYFzelONu8TNNJm+/MXsBxxr3Cafhfs+T9aOTqt7TM3Y42EiBPK/tq
         a5E/qjXeNYVuuEM/miwizSiuJKMI6AMbGm/EQZWMN7X0mfUW3VNoBgO6VIJsiwQaDqk7
         TQEA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=tXXK5Wkv;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id c8si6449445oih.25.2019.05.28.16.33.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 16:33:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=tXXK5Wkv;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4SNT0LH119660;
	Tue, 28 May 2019 23:33:26 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=message-id : subject
 : from : to : cc : date : in-reply-to : references : content-type :
 mime-version : content-transfer-encoding; s=corp-2018-07-02;
 bh=qZEaRDIPmwP5TWUCR9S3u/yLXWO2OSFxoldkS0AmjG0=;
 b=tXXK5WkvA3VpUTlG51P2q9LGfJkxovSGvJIwhPF0NNiu+pmrRrs643ObtsLlzxRZv9sL
 xGi67b35C30eA0gpzgCd7F8UFJTakd6EXWlodKDeKJ60hlPISFox2XuqHR9cIA7dhNTN
 Q5Lw2qFPToynBCudzAjqo23xQbAWky82hD/SJG6b8yHxFH/FmpNvWlBPdvbxfUAY8M+n
 Vx6af6q6yS6VUR4iO8Jx5PZrsb+QteyJjDVK43wT0JbTMcEcAMAf5nK5JLidAe2pkiIH
 EDCG69b49G78RsJVwupKHxQhnxG73NvIMsSpzN+lJa9ewDtd9ObQ1kGCJ+pwcgxn6TKn sg== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2120.oracle.com with ESMTP id 2spxbq6a0j-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 28 May 2019 23:33:26 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4SNWSwv154312;
	Tue, 28 May 2019 23:33:26 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3020.oracle.com with ESMTP id 2sqh73cyk2-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 28 May 2019 23:33:25 +0000
Received: from abhmp0007.oracle.com (abhmp0007.oracle.com [141.146.116.13])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x4SNXMjM008798;
	Tue, 28 May 2019 23:33:23 GMT
Received: from dhcp-10-65-132-79.vpn.oracle.com (/10.65.132.79)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 28 May 2019 16:33:22 -0700
Message-ID: <11193998209cc6ff34e7d704f081206b8787b174.camel@oracle.com>
Subject: Re: [PATCH v15 05/17] arms64: untag user pointers passed to memory
 syscalls
From: Khalid Aziz <khalid.aziz@oracle.com>
To: Catalin Marinas <catalin.marinas@arm.com>,
        Andrew Murray
	 <andrew.murray@arm.com>
Cc: Andrey Konovalov <andreyknvl@google.com>,
        Mark Rutland
 <mark.rutland@arm.com>, kvm@vger.kernel.org,
        Szabolcs Nagy
 <Szabolcs.Nagy@arm.com>,
        Will Deacon <will.deacon@arm.com>, dri-devel@lists.freedesktop.org,
        linux-mm@kvack.org, linux-kselftest@vger.kernel.org,
        Felix Kuehling <Felix.Kuehling@amd.com>,
        Vincenzo Frascino <vincenzo.frascino@arm.com>,
        Jacob Bramley
 <Jacob.Bramley@arm.com>,
        Leon Romanovsky <leon@kernel.org>, linux-rdma@vger.kernel.org,
        amd-gfx@lists.freedesktop.org, Dmitry Vyukov
 <dvyukov@google.com>,
        Dave Martin <Dave.Martin@arm.com>,
        Evgeniy Stepanov
 <eugenis@google.com>, linux-media@vger.kernel.org,
        Kevin Brodsky
 <kevin.brodsky@arm.com>,
        Kees Cook <keescook@chromium.org>,
        Ruben
 Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
        Ramana Radhakrishnan
 <Ramana.Radhakrishnan@arm.com>,
        Alex Williamson
 <alex.williamson@redhat.com>,
        Mauro Carvalho Chehab <mchehab@kernel.org>,
        linux-arm-kernel@lists.infradead.org,
        Kostya Serebryany <kcc@google.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Yishai Hadas
 <yishaih@mellanox.com>, linux-kernel@vger.kernel.org,
        Jens Wiklander
 <jens.wiklander@linaro.org>,
        Lee Smith <Lee.Smith@arm.com>,
        Alexander
 Deucher <Alexander.Deucher@amd.com>,
        Andrew Morton
 <akpm@linux-foundation.org>,
        Robin Murphy <robin.murphy@arm.com>,
        Christian Koenig <Christian.Koenig@amd.com>,
        Luc Van Oostenryck
 <luc.vanoostenryck@gmail.com>
Date: Tue, 28 May 2019 17:33:04 -0600
In-Reply-To: <20190528154057.GD32006@arrakis.emea.arm.com>
References: <cover.1557160186.git.andreyknvl@google.com>
	 <00eb4c63fefc054e2c8d626e8fedfca11d7c2600.1557160186.git.andreyknvl@google.com>
	 <20190527143719.GA59948@MBP.local>
	 <20190528145411.GA709@e119886-lin.cambridge.arm.com>
	 <20190528154057.GD32006@arrakis.emea.arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5-0ubuntu0.18.04.1 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9271 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=4 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905280148
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9271 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=4 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905280148
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-05-28 at 16:40 +0100, Catalin Marinas wrote:
> On Tue, May 28, 2019 at 03:54:11PM +0100, Andrew Murray wrote:
> > On Mon, May 27, 2019 at 03:37:20PM +0100, Catalin Marinas wrote:
> > > On Mon, May 06, 2019 at 06:30:51PM +0200, Andrey Konovalov wrote:
> > > > This patch is a part of a series that extends arm64 kernel ABI
> > > > to allow to
> > > > pass tagged user pointers (with the top byte set to something
> > > > else other
> > > > than 0x00) as syscall arguments.
> > > > 
> > > > This patch allows tagged pointers to be passed to the following
> > > > memory
> > > > syscalls: brk, get_mempolicy, madvise, mbind, mincore, mlock,
> > > > mlock2,
> > > > mmap, mmap_pgoff, mprotect, mremap, msync, munlock, munmap,
> > > > remap_file_pages, shmat and shmdt.
> > > > 
> > > > This is done by untagging pointers passed to these syscalls in
> > > > the
> > > > prologues of their handlers.
> > > > 
> > > > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > > 
> > > Actually, I don't think any of these wrappers get called (have
> > > you
> > > tested this patch?). Following commit 4378a7d4be30 ("arm64:
> > > implement
> > > syscall wrappers"), I think we have other macro names for
> > > overriding the
> > > sys_* ones.
> > 
> > What is the value in adding these wrappers?
> 
> Not much value, initially proposed just to keep the core changes
> small.
> I'm fine with moving them back in the generic code (but see below).
> 
> I think another aspect is how we define the ABI. Is allowing tags to
> mlock() for example something specific to arm64 or would sparc ADI
> need
> the same? In the absence of other architectures defining such ABI, my
> preference would be to keep the wrappers in the arch code.
> 
> Assuming sparc won't implement untagged_addr(), we can place the
> macros
> back in the generic code but, as per the review here, we need to be
> more
> restrictive on where we allow tagged addresses. For example, if
> mmap()
> gets a tagged address with MAP_FIXED, is it expected to return the
> tag?

I would recommend against any ABI differences between ARM64 MTE/TBI and
sparc ADI unless it simply can not be helped. My understanding of
MTE/TBI is limited, so I will explain how sparc ADI works. On sparc, a
tagged address has no meaning until following steps happen:

1. set the user mode PSTATE.mcde bit. This acts as the master switch to
enable ADI for a process.

2. set TTE.mcd bit on TLB entries that match the address range ADI is
being enabled on.

3. Store version tag for the range of addresses userspace wants ADI
enabled on using "stxa" instruction. These tags are stored in physical
memory by the memory controller.

Steps 1 and 2 are accomplished by userspace by calling mprotect() with
PROT_ADI. Tags are set by storing tags in a loop, for example:

        version = 10;
        tmp_addr = shmaddr;
        end = shmaddr + BUFFER_SIZE;
        while (tmp_addr < end) {
                asm volatile(
                        "stxa %1, [%0]0x90\n\t"
                        :
                        : "r" (tmp_addr), "r" (version));
                tmp_addr += adi_blksz;
        }

With these semantics, giving mmap() or shamat() a tagged address is
meaningless since no tags have been stored at the addresses mmap() will
allocate and one can not store tags before memory range has been
allocated. If we choose to allow tagged addresses to come into mmap()
and shmat(), sparc code can strip the tags unconditionally and that may
help simplify ABI and/or code.

> 
> My thoughts on allowing tags (quick look):
> 
> brk - no
> get_mempolicy - yes
> madvise - yes
> mbind - yes
> mincore - yes
> mlock, mlock2, munlock - yes
> mmap - no (we may change this with MTE but not for TBI)
> mmap_pgoff - not used on arm64
> mprotect - yes
> mremap - yes for old_address, no for new_address (on par with mmap)
> msync - yes
> munmap - probably no (mmap does not return tagged ptrs)
> remap_file_pages - no (also deprecated syscall)
> shmat, shmdt - shall we allow tagged addresses on shared memory?
> 
> The above is only about the TBI ABI while ignoring hardware MTE. For
> the
> latter, we may want to change the mmap() to allow pre-colouring on
> page
> fault which means that munmap()/mprotect() should also support tagged
> pointers. Possibly mremap() as well but we need to decide whether it
> should allow re-colouring the page (probably no, in which case
> old_address and new_address should have the same tag). For some of
> these
> we'll end up with arm64 specific wrappers again, unless sparc ADI
> adopts
> exactly the same ABI restrictions.
> 

Let us keep any restrictions common across ARM64 and sparc. pre-
coloring on sparc in the kernel would mean kernel will have to execute
stxa instructions in a loop for each page being faulted in. Not that
big a deal but doesn't that assume the entire page has the same tag
which is dedcued from the upper bits of address? Shouldn't we support
tags at the same granularity level as what the hardware supports? We
went through this discussion for sparc and decision was to support tags
at the same granularity as hardware. That means we can not deduce tags
from the first address that pioints into an mmap or shmat region. Those
tags and the upper bytes of colored address could change for every
cacheline sized block (64-bytes on sparc M7). We can try to store tags
for an entire region in vma but that is expensive, plus on sparc tags
are set in userspace with no participation from kernel and now we need
a way for userspace to communicate the tags to kernel. From sparc point
of view, making kernel responsible for assigning tags to a page on page
fault is full of pitfalls.

Thanks,
Khalid

