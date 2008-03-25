Date: Tue, 25 Mar 2008 15:30:59 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC 8/8] x86_64: Support for new UV apic
Message-ID: <20080325143059.GB11323@elte.hu>
References: <20080324182122.GA28327@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080324182122.GA28327@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Jack Steiner <steiner@sgi.com> wrote:

> Index: linux/arch/x86/kernel/genapic_64.c

> @@ -69,7 +73,16 @@ void send_IPI_self(int vector)
>  
>  unsigned int get_apic_id(void)
>  {
> -	return (apic_read(APIC_ID) >> 24) & 0xFFu;
> +	unsigned int id;
> +
> +	preempt_disable();
> +	id = apic_read(APIC_ID);
> +	if (uv_system_type >= UV_X2APIC)
> +		id  |= __get_cpu_var(x2apic_extra_bits);
> +	else
> +		id = (id >> 24) & 0xFFu;;
> +	preempt_enable();
> +	return id;

dont we want to put get_apic_id() into struct genapic instead? We 
already have ID management there.

also, we want to unify 32-bit and 64-bit genapic code and just have 
genapic all across x86.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
