Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id B070A6B0005
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 01:27:12 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id y7-v6so9382125plt.17
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 22:27:12 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id az9-v6si792129plb.454.2018.06.25.22.27.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jun 2018 22:27:11 -0700 (PDT)
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 846EA26521
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 05:27:10 +0000 (UTC)
Received: by mail-wm0-f48.google.com with SMTP id z13-v6so279039wma.5
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 22:27:10 -0700 (PDT)
MIME-Version: 1.0
References: <20180607143807.3611-1-yu-cheng.yu@intel.com>
In-Reply-To: <20180607143807.3611-1-yu-cheng.yu@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 25 Jun 2018 22:26:57 -0700
Message-ID: <CALCETrWYx5nCtwGAqTZBWOB+aw+eEcnQhe6Sn1o+O356g7Km9A@mail.gmail.com>
Subject: Re: [PATCH 00/10] Control Flow Enforcement - Part (3)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, Linux API <linux-api@vger.kernel.org>, Jann Horn <jannh@google.com>, Florian Weimer <fweimer@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Thu, Jun 7, 2018 at 7:41 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>
> This series introduces CET - Shadow stack

I think you should add some mitigation against sigreturn-oriented
programming.  How about creating some special token on the shadow
stack that indicates the presence of a signal frame at a particular
address when delivering a signal and verifying and popping that token
in sigreturn?  The token could be literally the address of the signal
frame, and you could make this unambiguous by failing sigreturn if CET
is on and the signal frame is in executable memory.

IOW, it would be a shame if sigreturn() itself became a convenient
CET-bypassing gadget.

--Andy
