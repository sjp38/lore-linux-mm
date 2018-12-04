Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 578E66B6DFF
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 04:31:24 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id f24so16903510ioh.21
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 01:31:24 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id n21si9369690jad.38.2018.12.04.01.31.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Dec 2018 01:31:23 -0800 (PST)
Date: Tue, 4 Dec 2018 10:31:16 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC v2 13/13] keys/mktme: Support CPU Hotplug for MKTME keys
Message-ID: <20181204093116.GV11614@hirez.programming.kicks-ass.net>
References: <cover.1543903910.git.alison.schofield@intel.com>
 <c14d24b09ee2ae37ea4106726ce8fe2aea31f6c7.1543903910.git.alison.schofield@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c14d24b09ee2ae37ea4106726ce8fe2aea31f6c7.1543903910.git.alison.schofield@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alison Schofield <alison.schofield@intel.com>
Cc: dhowells@redhat.com, tglx@linutronix.de, jmorris@namei.org, mingo@redhat.com, hpa@zytor.com, bp@alien8.de, luto@kernel.org, kirill.shutemov@linux.intel.com, dave.hansen@intel.com, kai.huang@intel.com, jun.nakajima@intel.com, dan.j.williams@intel.com, jarkko.sakkinen@intel.com, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

On Mon, Dec 03, 2018 at 11:40:00PM -0800, Alison Schofield wrote:
>  static int mktme_program_system(struct mktme_key_program *key_program,
> -				cpumask_var_t mktme_cpumask)
> +				cpumask_var_t mktme_cpumask, int hotplug)
>  {
>  	struct mktme_hw_program_info info = {
>  		.key_program = key_program,
>  		.status = MKTME_PROG_SUCCESS,
>  	};
> -	get_online_cpus();
> -	on_each_cpu_mask(mktme_cpumask, mktme_program_package, &info, 1);
> -	put_online_cpus();
> +
> +	if (!hotplug) {
> +		get_online_cpus();
> +		on_each_cpu_mask(mktme_cpumask, mktme_program_package,
> +				 &info, 1);
> +		put_online_cpus();
> +	} else {
> +		on_each_cpu_mask(mktme_cpumask, mktme_program_package,
> +				 &info, 1);
> +	}
>  
>  	return info.status;
>  }

That is pretty horrible; and I think easily avoided.
