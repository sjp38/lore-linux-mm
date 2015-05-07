Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id 99C1D6B0032
	for <linux-mm@kvack.org>; Thu,  7 May 2015 19:24:18 -0400 (EDT)
Received: by qkgx75 with SMTP id x75so38480459qkg.1
        for <linux-mm@kvack.org>; Thu, 07 May 2015 16:24:18 -0700 (PDT)
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com. [209.85.216.182])
        by mx.google.com with ESMTPS id de1si3645994qcb.44.2015.05.07.16.24.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 May 2015 16:24:17 -0700 (PDT)
Received: by qcvo8 with SMTP id o8so5663664qcv.0
        for <linux-mm@kvack.org>; Thu, 07 May 2015 16:24:17 -0700 (PDT)
Message-ID: <554BF418.5080200@hurleysoftware.com>
Date: Thu, 07 May 2015 19:24:08 -0400
From: Peter Hurley <peter@hurleysoftware.com>
MIME-Version: 1.0
Subject: Re: [PATCH] devpts: If initialization failed, don't crash when opening
 /dev/ptmx
References: <20150507003547.GA6862@jtriplet-mobl1> <20150507155919.16ab7177e4956d8f47803750@linux-foundation.org>
In-Reply-To: <20150507155919.16ab7177e4956d8f47803750@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Josh Triplett <josh@joshtriplett.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, Iulia Manda <iulia.manda21@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Fabian Frederick <fabf@skynet.be>, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On 05/07/2015 06:59 PM, Andrew Morton wrote:
> On Wed, 6 May 2015 17:35:47 -0700 Josh Triplett <josh@joshtriplett.org> wrote:
> 
>> If devpts failed to initialize, it would store an ERR_PTR in the global
>> devpts_mnt.  A subsequent open of /dev/ptmx would call devpts_new_index,
>> which would dereference devpts_mnt and crash.
>>
>> Avoid storing invalid values in devpts_mnt; leave it NULL instead.
>> Make both devpts_new_index and devpts_pty_new fail gracefully with
>> ENODEV in that case, which then becomes the return value to the
>> userspace open call on /dev/ptmx.
> 
> It looks like the system is pretty crippled if init_devptr_fs() fails. 
> Can the user actually get access to consoles and do useful things in
> this situation?  Maybe it would be better to just give up and panic?

A single-user console is definitely reachable without devpts.
>From there, one could fixup to a not-broken kernel.

Regards,
Peter Hurley

PS - But I saw you already added these to -mm

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
