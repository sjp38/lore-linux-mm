From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH 2/3] x86, MCE: Avoid potential deadlock in MCE context
Date: Tue, 22 Jul 2014 19:26:09 +0200
Message-ID: <20140722172609.GI6462@pd.tnic>
References: <1405478082-30757-1-git-send-email-gong.chen@linux.intel.com>
 <1405478082-30757-3-git-send-email-gong.chen@linux.intel.com>
 <20140721084737.GA10016@pd.tnic>
 <3908561D78D1C84285E8C5FCA982C28F32870C55@ORSMSX114.amr.corp.intel.com>
 <20140721214116.GC11555@pd.tnic>
 <3908561D78D1C84285E8C5FCA982C28F32871435@ORSMSX114.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F32871435@ORSMSX114.amr.corp.intel.com>
Sender: linux-acpi-owner@vger.kernel.org
To: "Luck, Tony" <tony.luck@intel.com>
Cc: "Chen, Gong" <gong.chen@linux.intel.com>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>
List-Id: linux-mm.kvack.org

On Mon, Jul 21, 2014 at 10:03:04PM +0000, Luck, Tony wrote:
> > And drop all the homegrown other stuff like mce_ring and all?
> 
> mce_ring should be easy ... the "mce" structure has the address
> from which we can easily get the pfn to pass into the action-optional
> recovery path.  Only thing missing is a direct indication that this mce
> does contain an AO error that needs to be processed. We could
> re-invoke mce_severity() to figure it out again - or just add a flag
> somewhere.

Right, so if we're going to clean up this mess, I think we should strive
for having a single ring buffer which contains all the MCEs and which we
can iterate over at leisure, either in IRQ context if some of them have
been reported through real exceptions or in process context if they're
simple CEs.

Once they've been eaten by something, we simply remove them from that
buffer and that's it. But sure, one lockless buffer which works in all
contexts would be much better than growing stuff here and there with
different semantics and context usage.

Thanks.

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--
