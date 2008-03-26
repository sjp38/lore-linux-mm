Date: Wed, 26 Mar 2008 07:53:17 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 09/10] x86: oprofile: remove NR_CPUS arrays in
	arch/x86/oprofile/nmi_int.c
Message-ID: <20080326065317.GH18301@elte.hu>
References: <20080325220650.835342000@polaris-admin.engr.sgi.com> <20080325220652.088163000@polaris-admin.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080325220652.088163000@polaris-admin.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Philippe Elie <phil.el@wanadoo.fr>
List-ID: <linux-mm.kvack.org>

* Mike Travis <travis@sgi.com> wrote:

> Change the following arrays sized by NR_CPUS to be PERCPU variables:
> 
> 	static struct op_msrs cpu_msrs[NR_CPUS];
> 	static unsigned long saved_lvtpc[NR_CPUS];
> 
> Also some minor complaints from checkpatch.pl fixed.

thanks, applied.

> All changes were transparent except for:
> 
>  static void nmi_shutdown(void)
>  {
> +	struct op_msrs *msrs = &__get_cpu_var(cpu_msrs);
>  	nmi_enabled = 0;
>  	on_each_cpu(nmi_cpu_shutdown, NULL, 0, 1);
>  	unregister_die_notifier(&profile_exceptions_nb);
> -	model->shutdown(cpu_msrs);
> +	model->shutdown(msrs);
>  	free_msrs();
>  }
> 
> The existing code passed a reference to cpu 0's instance of struct 
> op_msrs to model->shutdown, whilst the other functions are passed a 
> reference to <this cpu's> instance of a struct op_msrs.  This seemed 
> to be a bug to me even though as long as cpu 0 and <this cpu> are of 
> the same type it would have the same effect...?

i dont think this has any real effect in practice (the model pointers 
are not expected to change across cpus on the same system) - but in any 
case i've promoted your observation to the main portion of the changelog 
so that we'll have notice of this.

(someone might want to play with simulating a weaker CPU on a secondary 
core, but we've got tons of other assumptions on CPU type symmetry.)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
