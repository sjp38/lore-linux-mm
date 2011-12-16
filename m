Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 510286B004D
	for <linux-mm@kvack.org>; Fri, 16 Dec 2011 03:40:24 -0500 (EST)
From: Petr Tesarik <ptesarik@suse.cz>
Subject: Re: [PATCH] Do not round per_cpu_ptr_to_phys to page boundary
Date: Fri, 16 Dec 2011 09:40:20 +0100
References: <201112140033.58951.ptesarik@suse.cz> <CAOS58YP8o9xQvZJtpEJobChhJ+pSDQ9PqDwaXFS_h+JFd65jOw@mail.gmail.com> <201112160904.23252.ptesarik@suse.cz>
In-Reply-To: <201112160904.23252.ptesarik@suse.cz>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Message-Id: <201112160940.20909.ptesarik@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Vivek Goyal <vgoyal@redhat.com>, surovegin@google.com, gthelen@google.com

Ignore my patch. I can see, a patch has already been accepted.

I only replied too fast (before I read the rest of the thread).

Petr

Dne P=E1 16. prosince 2011 09:04:23 Petr Tesarik napsal(a):
> The phys_addr_t per_cpu_ptr_to_phys() function ignores the offset within a
> page, whenever not using a simple translation using __pa().
>=20
> Without this patch /sys/devices/system/cpu/cpu*/crash_notes shows incorre=
ct
> values, which breaks kdump. Other things may also be broken.
>=20
> Signed-off-by: Petr Tesarik <ptesarik@suse.cz>
>=20
> diff --git a/mm/percpu.c b/mm/percpu.c
> index 3bb810a..1a1b5ac 100644
> --- a/mm/percpu.c
> +++ b/mm/percpu.c
> @@ -998,6 +998,7 @@ phys_addr_t per_cpu_ptr_to_phys(void *addr)
>  	bool in_first_chunk =3D false;
>  	unsigned long first_low, first_high;
>  	unsigned int cpu;
> +	phys_addr_t page_addr;
>=20
>  	/*
>  	 * The following test on unit_low/high isn't strictly
> @@ -1023,9 +1024,10 @@ phys_addr_t per_cpu_ptr_to_phys(void *addr)
>  		if (!is_vmalloc_addr(addr))
>  			return __pa(addr);
>  		else
> -			return page_to_phys(vmalloc_to_page(addr));
> +			page_addr =3D page_to_phys(vmalloc_to_page(addr));
>  	} else
> -		return page_to_phys(pcpu_addr_to_page(addr));
> +		page_addr =3D page_to_phys(pcpu_addr_to_page(addr));
> +	return page_addr + offset_in_page(addr);
>  }
>=20
>  /**
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign
> http://stopthemeter.ca/ Don't email: <a href=3Dmailto:"dont@kvack.org">
> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
