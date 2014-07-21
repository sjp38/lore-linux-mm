From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH 2/3] x86, MCE: Avoid potential deadlock in MCE context
Date: Mon, 21 Jul 2014 23:41:16 +0200
Message-ID: <20140721214116.GC11555@pd.tnic>
References: <1405478082-30757-1-git-send-email-gong.chen@linux.intel.com>
 <1405478082-30757-3-git-send-email-gong.chen@linux.intel.com>
 <20140721084737.GA10016@pd.tnic>
 <3908561D78D1C84285E8C5FCA982C28F32870C55@ORSMSX114.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F32870C55@ORSMSX114.amr.corp.intel.com>
Sender: linux-acpi-owner@vger.kernel.org
To: "Luck, Tony" <tony.luck@intel.com>
Cc: "Chen, Gong" <gong.chen@linux.intel.com>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>
List-Id: linux-mm.kvack.org

On Mon, Jul 21, 2014 at 05:14:06PM +0000, Luck, Tony wrote:
> We've evolved a bunch of mechanisms:
> 
> 1) mce_ring: to pass pfn for AO errors from MCE context to a work thread
> 2) mce_info: to pass pfn for AR errors from MCE context to same process running in process context
> 3) mce_log: to pass entire "mce" structures from any context (MCE, CMCI, or init-time) to /dev/mcelog
> 
> something simpler might be nice - but a generic thing that is overkill for each of the
> specialized uses might not necessarily be an improvement.
> 
> E.g. #3 above has a fixed capacity (MCE_LOG_LEN) and just drops any extras if it should fill

Gong's too. Famous last words:

	/* two pages should be enough */
	pages = 2;

> up (deliberately, because we almost always prefer to see the first bunch of errors rather
> than the newest).
> 
> > I think it would be a *lot* simpler if you modify the logic to put all
> > errors into the ring and remove the call chain call from mce_log().
> 
> I was actually wondering about going in the other direction. Make the
> /dev/mcelog code register a notifier on x86_mce_decoder_chain (and
> perhaps move all the /dev/mcelog functions out of mce.c into an actual
> driver file).

For easier deletion later. :-P

> Then use Chen Gong's NMI safe code to just unconditionally make safe
> copies of anything that gets passed to mce_log() and run all the
> notifiers from his do_mce_irqwork().

And drop all the homegrown other stuff like mce_ring and all? If this
gets designed right and it is well thought out - not hastily coded out -
it will probably be better, yes.

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--
