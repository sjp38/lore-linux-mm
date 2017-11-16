Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id D07ED4402ED
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 14:19:35 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id w205so45846oig.7
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 11:19:35 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r21si640203ota.123.2017.11.16.11.19.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Nov 2017 11:19:34 -0800 (PST)
Date: Thu, 16 Nov 2017 20:19:31 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 23/30] x86, kaiser: use PCID feature to make user and
 kernel switches faster
Message-ID: <20171116191931.GC2344@redhat.com>
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
 <20171110193150.1E736CE0@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171110193150.1E736CE0@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

Hello,

On Fri, Nov 10, 2017 at 11:31:50AM -0800, Dave Hansen wrote:
> Hugh Dickins also points out that PCIDs really have two distinct
> use-cases in the context of KAISER.  The first way they can be used

I don't see why you try to retain such a minor optimization for newer
Intel chips when at the same you prevent KAISER to run with good
performance on older Intel chips like SandyBridge/IvyBridge which
would create a major performance regression for those two. I'd prefer
if you reverse the PCID feature of v4.14 when KASIER is enabled (at
build time would be enough initially), and you use just two asids to
only accelerate enter/exit kernel and you flush the whole TLB over mm
switch like Hugh suggested. It may not even be worth to flush over
cr4, as you've only two asids to deal with anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
