From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v7 1/3] x86: Add classes to exception tables
Date: Fri, 8 Jan 2016 18:20:35 +0100
Message-ID: <20160108172035.GE12132@pd.tnic>
References: <b5dc7a1ee68f48dc61c10959b2209851f6eb6aab.1451952351.git.tony.luck@intel.com>
 <20160106123346.GC19507@pd.tnic>
 <CALCETrVXD5YB_1UzR4LnSOCgV+ZzhDi9JRZrcxhMAjbvSzO6MQ@mail.gmail.com>
 <20160106175948.GA16647@pd.tnic>
 <CALCETrXsC9eiQ8yF555-8G88pYEms4bDsS060e24FoadAOK+kw@mail.gmail.com>
 <20160106194222.GC16647@pd.tnic>
 <20160107121131.GB23768@pd.tnic>
 <20160108014526.GA31242@agluck-desk.sc.intel.com>
 <20160108103733.GC12132@pd.tnic>
 <3908561D78D1C84285E8C5FCA982C28F39FA7163@ORSMSX114.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F39FA7163@ORSMSX114.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, Robert <elliott@hpe.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>
List-Id: linux-mm.kvack.org

On Fri, Jan 08, 2016 at 04:29:49PM +0000, Luck, Tony wrote:
> I thought the guideline was that new features are GPL, but changes
> to existing features shouldn't break by adding new GPL requirements.
> 
> The point is moot though because  the shared hallucinations wore
> off this morning and I realized that having the "handler" be a pointer
> to a function can't work. We're storing the 32-bit signed offset from
> the extable to the target address. This is fine if the table and the
> address are close together. But for modules we have an exception
> table wherever vmalloc() loaded the module, and a function back
> in the base kernel.

Whoops, true story.

> So back to your ".long 0" for the default case.  And if we want to allow
> modules to use any of the new handlers, then we can't use
> relative function pointers for them either.
> 
> So I'm looking at making the new field just a simple integer and using
> it to index an array of function pointers (like in v7).

Right, that sounds good too. I guess we can even split the integer into

[0 ... 7][8 ... 31]

where slice [0:7] is an index into the handlers array and the remaining
unused 24-bits could be used for other stuff later. Normal addition as a
way to OR values should work.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
