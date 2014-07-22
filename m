Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 66BE56B003A
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 03:23:31 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id f8so5403166wiw.12
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 00:23:30 -0700 (PDT)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id ar1si33162982wjc.34.2014.07.22.00.23.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Jul 2014 00:23:28 -0700 (PDT)
Received: by mail-wi0-f182.google.com with SMTP id d1so5315608wiv.3
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 00:23:28 -0700 (PDT)
Date: Tue, 22 Jul 2014 09:23:37 +0200
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [PATCH v2 00/25] AMDKFD kernel driver
Message-ID: <20140722072337.GG15237@phenom.ffwll.local>
References: <20140720174652.GE3068@gmail.com>
 <53CD0961.4070505@amd.com>
 <53CD17FD.3000908@vodafone.de>
 <53CD1FB6.1000602@amd.com>
 <20140721155437.GA4519@gmail.com>
 <53CD5122.5040804@amd.com>
 <20140721181433.GA5196@gmail.com>
 <53CD5DBC.7010301@amd.com>
 <20140721185940.GA5278@gmail.com>
 <53CD68BF.4020308@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53CD68BF.4020308@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oded Gabbay <oded.gabbay@amd.com>
Cc: Jerome Glisse <j.glisse@gmail.com>, Andrew Lewycky <Andrew.Lewycky@amd.com>, Michel =?iso-8859-1?Q?D=E4nzer?= <michel.daenzer@amd.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-mm <linux-mm@kvack.org>, Evgeny Pinchuk <Evgeny.Pinchuk@amd.com>, Alexey Skidanov <Alexey.Skidanov@amd.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Jul 21, 2014 at 10:23:43PM +0300, Oded Gabbay wrote:
> But Jerome, the core problem still remains in effect, even with your
> suggestion. If an application, either via userspace queue or via ioctl,
> submits a long-running kernel, than the CPU in general can't stop the
> GPU from running it. And if that kernel does while(1); than that's it,
> game's over, and no matter how you submitted the work. So I don't really
> see the big advantage in your proposal. Only in CZ we can stop this wave
> (by CP H/W scheduling only). What are you saying is basically I won't
> allow people to use compute on Linux KV system because it _may_ get the
> system stuck.
> 
> So even if I really wanted to, and I may agree with you theoretically on
> that, I can't fulfill your desire to make the "kernel being able to
> preempt at any time and be able to decrease or increase user queue
> priority so overall kernel is in charge of resources management and it
> can handle rogue client in proper fashion". Not in KV, and I guess not
> in CZ as well.

At least on intel the execlist stuff which is used for preemption can be
used by both the cpu and the firmware scheduler. So we can actually
preempt when doing cpu scheduling.

It sounds like current amd hw doesn't have any preemption at all. And
without preemption I don't think we should ever consider to allow
userspace to directly submit stuff to the hw and overload. Imo the kernel
_must_ sit in between and reject clients that don't behave. Of course you
can only ever react (worst case with a gpu reset, there's code floating
around for that on intel-gfx), but at least you can do something.

If userspace has a direct submit path to the hw then this gets really
tricky, if not impossible.
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
