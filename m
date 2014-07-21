From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH 2/3] x86, MCE: Avoid potential deadlock in MCE context
Date: Mon, 21 Jul 2014 10:47:37 +0200
Message-ID: <20140721084737.GA10016@pd.tnic>
References: <1405478082-30757-1-git-send-email-gong.chen@linux.intel.com>
 <1405478082-30757-3-git-send-email-gong.chen@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1405478082-30757-3-git-send-email-gong.chen@linux.intel.com>
Sender: linux-acpi-owner@vger.kernel.org
To: "Chen, Gong" <gong.chen@linux.intel.com>
Cc: tony.luck@intel.com, linux-acpi@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-Id: linux-mm.kvack.org

On Tue, Jul 15, 2014 at 10:34:41PM -0400, Chen, Gong wrote:
> When Uncorrected error happens, an MCE will be raised. Some
> notification callbacks will be called in MCE context. If
> some notification call printk it will cause potential
> deadlock because MCE can preempt normal interrupts like NMI does.
> 
> Since printk is not safe in MCE context. So a lock-less memory
> allocator (genpool) is used to save information which are
> organized via a lock-less list. Print will be delayed into IRQ
> context via irq_work. This idea is inspired by APEI/GHES driver.

This patch is overengineered even though we already have both process
context work and irq work facilities in place.

We also already have mce_ring where we add MCE signatures in #MC
context. Well, only for AO errors with usable addresses for now, at
least.

And we empty that ring in mce_process_work().

I think it would be a *lot* simpler if you modify the logic to put all
errors into the ring and remove the call chain call from mce_log(). I'm
looking at mce_report_event() which even does the irq_work stuff if
we need to raise an IPI *during* the MCE so that stuff gets processed
*before* we return to userspace.

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--
