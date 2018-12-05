Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id CFE1C6B72AF
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 00:33:42 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id c14so14155359pls.21
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 21:33:42 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id j66si21031136pfb.182.2018.12.04.21.33.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 21:33:41 -0800 (PST)
Date: Tue, 4 Dec 2018 21:36:15 -0800
From: Alison Schofield <alison.schofield@intel.com>
Subject: Re: [RFC v2 13/13] keys/mktme: Support CPU Hotplug for MKTME keys
Message-ID: <20181205053615.GD18596@alison-desk.jf.intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
 <c14d24b09ee2ae37ea4106726ce8fe2aea31f6c7.1543903910.git.alison.schofield@intel.com>
 <20181204093116.GV11614@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181204093116.GV11614@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: dhowells@redhat.com, tglx@linutronix.de, jmorris@namei.org, mingo@redhat.com, hpa@zytor.com, bp@alien8.de, luto@kernel.org, kirill.shutemov@linux.intel.com, dave.hansen@intel.com, kai.huang@intel.com, jun.nakajima@intel.com, dan.j.williams@intel.com, jarkko.sakkinen@intel.com, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

On Tue, Dec 04, 2018 at 10:31:16AM +0100, Peter Zijlstra wrote:
> On Mon, Dec 03, 2018 at 11:40:00PM -0800, Alison Schofield wrote:
> >  static int mktme_program_system(struct mktme_key_program *key_program,
> > -				cpumask_var_t mktme_cpumask)
> > +				cpumask_var_t mktme_cpumask, int hotplug)
> >  {
> >  	struct mktme_hw_program_info info = {
> >  		.key_program = key_program,
> >  		.status = MKTME_PROG_SUCCESS,
> >  	};
> > -	get_online_cpus();
> > -	on_each_cpu_mask(mktme_cpumask, mktme_program_package, &info, 1);
> > -	put_online_cpus();
> > +
> > +	if (!hotplug) {
> > +		get_online_cpus();
> > +		on_each_cpu_mask(mktme_cpumask, mktme_program_package,
> > +				 &info, 1);
> > +		put_online_cpus();
> > +	} else {
> > +		on_each_cpu_mask(mktme_cpumask, mktme_program_package,
> > +				 &info, 1);
> > +	}
> >  
> >  	return info.status;
> >  }
> 
> That is pretty horrible; and I think easily avoided.
Agree it's ugly. Not sure we share the same reasoning. I realize that
the hotplug case is on the current cpu and so that whole
one_each_cpu_mask() call is not needed. mktme_program_package() can just
be called on the current cpu.

The ugliness that haunts me is that I wanted to reuse this code path,
and so I passed that 'hotplug' parameter along as a differentiator
between hotplug & 'typical' key programming. 
I'll rework this.
