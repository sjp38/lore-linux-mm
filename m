Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id C97916B00A7
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 10:26:24 -0500 (EST)
Received: by mail-la0-f46.google.com with SMTP id gm9so847375lab.19
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 07:26:23 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i3si6710652lae.59.2014.11.05.07.26.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Nov 2014 07:26:23 -0800 (PST)
Message-ID: <545A419C.3090900@suse.cz>
Date: Wed, 05 Nov 2014 16:26:20 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: Early test: hangs in mm/compact.c w. Linus's 12d7aacab56e9ef185c
References: <12996532.NCRhVKzS9J@xorhgos3.pefnos> <54589465.3080708@suse.cz> <2357788.X5UHX7WJZF@xorhgos3.pefnos>
In-Reply-To: <2357788.X5UHX7WJZF@xorhgos3.pefnos>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "P. Christeas" <xrg@linux.gr>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, lkml <linux-kernel@vger.kernel.org>

On 11/04/2014 10:36 AM, P. Christeas wrote:
> On Tuesday 04 November 2014, Vlastimil Babka wrote:
>> Please do keep testing (and see below what we need), and don't try
>> another tree - it's 3.18 we need to fix!
> Let me apologize/warn you about the poor quality of this report (and debug 
> data).
> It is on a system meant for everyday desktop usage, not kernel development. 
> Thus, it is tuned to be "slightly" debuggable ; mostly for performance.
> 
>> I'm not sure what you mean by "race" here and your snippet is
>> unfortunately just a small portion of the output ...
> 
> It is a shot in the dark. System becomes non-responsive (narrowed to desktop 
> apps waiting each other, or the X+kwin blocking), I can feel the CPU heating 
> and /sometimes/ disk I/O.
> 
> No BUG, Oops or any kernel message. (is printk level 4 adequate? )
> 
> Then, I try to drop to a console and collect as much data as possible with 
> SysRq.
> 
> The snippet I'd sent you is from all-cpus-backtrace (l), trying to see which 
> traces appear consistently during the lockup. There is also the huge traces of 
> "task-states" (t), but I reckon they are too noisy.
> That trace also matches the usage profile, because AFAICG[uess] the issue 
> appears when allocating during I/O load. 
> 
> After turning on full-preemption, I have been able to terminate/kill all tasks 
> and continue with same kernel but new userspace.
> 
>> OK so the process is not dead due to the problem? That probably rules
>> out some kinds of errors but we still need the full output. Thanks in
>> advance. 
>> I'm not aware of this, CCing lkml for wider coverage.
> 
> Thank you. As I've told in the first mail, this is an early report of possible 
> 3.18 regression. I'm trying to narrow down the case and make it reproducible 
> or get a good trace.

I see. I've tried to reproduce such issues with 3.18-rc3 but wasn't successful.
But I noticed a possible issue that could lead to your problem.
Can you please try the following patch?

--------8<-------
