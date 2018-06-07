Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 63E736B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 14:22:07 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id f35-v6so5810133plb.10
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 11:22:07 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t128-v6si44391300pgt.368.2018.06.07.11.22.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 11:22:05 -0700 (PDT)
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 3B2642089F
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 18:22:05 +0000 (UTC)
Received: by mail-wm0-f42.google.com with SMTP id x6-v6so19628121wmc.3
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 11:22:05 -0700 (PDT)
MIME-Version: 1.0
References: <20180607143807.3611-1-yu-cheng.yu@intel.com> <20180607143807.3611-5-yu-cheng.yu@intel.com>
In-Reply-To: <20180607143807.3611-5-yu-cheng.yu@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 7 Jun 2018 11:21:51 -0700
Message-ID: <CALCETrUqXvh2FDXe6bveP10TFpzptEyQe2=mdfZFGKU0T+NXsA@mail.gmail.com>
Subject: Re: [PATCH 04/10] x86/cet: Handle thread shadow stack
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, Florian Weimer <fweimer@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Thu, Jun 7, 2018 at 7:41 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>
> When fork() specifies CLONE_VM but not CLONE_VFORK, the child
> needs a separate program stack and a separate shadow stack.
> This patch handles allocation and freeing of the thread shadow
> stack.

Aha -- you're trying to make this automatic.  I'm not convinced this
is a good idea.  The Linux kernel has a long and storied history of
enabling new hardware features in ways that are almost entirely
useless for userspace.

Florian, do you have any thoughts on how the user/kernel interaction
for the shadow stack should work?  My intuition would be that all
shadow stack management should be entirely controlled by userspace --
newly cloned threads (with CLONE_VM) should have no shadow stack
initially, and newly started processes should have no shadow stack
until they ask for one.  If it would be needed for optimization, there
could some indication in an ELF binary that it is requesting an
initial shadow stack.

But maybe some kind of automation like this patch does is actually reasonable.

--Andy
