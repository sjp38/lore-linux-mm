Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f54.google.com (mail-oa0-f54.google.com [209.85.219.54])
	by kanga.kvack.org (Postfix) with ESMTP id 716E16B0039
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 06:25:44 -0500 (EST)
Received: by mail-oa0-f54.google.com with SMTP id h16so18276216oag.13
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 03:25:44 -0800 (PST)
Received: from devils.ext.ti.com (devils.ext.ti.com. [198.47.26.153])
        by mx.google.com with ESMTPS id t5si56713933oem.66.2013.12.05.03.25.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 05 Dec 2013 03:25:43 -0800 (PST)
Message-ID: <52A062A0.3070005@ti.com>
Date: Thu, 5 Dec 2013 13:25:20 +0200
From: Tomi Valkeinen <tomi.valkeinen@ti.com>
MIME-Version: 1.0
Subject: Re: OMAPFB: CMA allocation failures
References: <1847426616.52843.1383681351015.JavaMail.apache@mail83.abv.bg> <A5506022381E423385022F79B40C6FAB@ivogl>
In-Reply-To: <A5506022381E423385022F79B40C6FAB@ivogl>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="0KsTXS7CrcCAvpLJcviKXk4BOJtP4liIh"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ivajlo Dimitrov <ivo.g.dimitrov.75@gmail.com>
Cc: minchan@kernel.org, pavel@ucw.cz, sre@debian.org, pali.rohar@gmail.com, pc+n900@asdf.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

--0KsTXS7CrcCAvpLJcviKXk4BOJtP4liIh
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 2013-11-30 12:00, Ivajlo Dimitrov wrote:
> Ping?
>=20
> ----- Original Message ----- From: "=D0=98=D0=B2=D0=B0=D0=B9=D0=BB=D0=BE=
 =D0=94=D0=B8=D0=BC=D0=B8=D1=82=D1=80=D0=BE=D0=B2" <freemangordon@abv.bg>=

> To: "Tomi Valkeinen" <tomi.valkeinen@ti.com>
> Cc: <minchan@kernel.org>; <pavel@ucw.cz>; <sre@debian.org>;
> <pali.rohar@gmail.com>; <pc+n900@asdf.org>;
> <linux-kernel@vger.kernel.org>; <linux-mm@kvack.org>
> Sent: Tuesday, November 05, 2013 9:55 PM
> Subject: Re: OMAPFB: CMA allocation failures
>=20
>=20
>>
>>
>>
>>
>>
>> >-------- =D0=9E=D1=80=D0=B8=D0=B3=D0=B8=D0=BD=D0=B0=D0=BB=D0=BD=D0=BE=
 =D0=BF=D0=B8=D1=81=D0=BC=D0=BE --------
>> >=D0=9E=D1=82:  Tomi Valkeinen
>> >=D0=9E=D1=82=D0=BD=D0=BE=D1=81=D0=BD=D0=BE: Re: OMAPFB: CMA allocatio=
n failures
>> >=D0=94=D0=BE: =D0=98=D0=B2=D0=B0=D0=B9=D0=BB=D0=BE =D0=94=D0=B8=D0=BC=
=D0=B8=D1=82=D1=80=D0=BE=D0=B2
>> >=D0=98=D0=B7=D0=BF=D1=80=D0=B0=D1=82=D0=B5=D0=BD=D0=BE =D0=BD=D0=B0: =
=D0=A1=D1=80=D1=8F=D0=B4=D0=B0, 2013, =D0=9E=D0=BA=D1=82=D0=BE=D0=BC=D0=B2=
=D1=80=D0=B8 30 14:19:32 EET
>> >
>> >I really dislike the idea of adding the omap vram allocator back. The=
n
>> >again, if the CMA doesn't work, something has to be done.
>> >
>>
>> If I got Minchan Kim's explanation correctly, CMA simply can't be used=

>> for allocation of framebuffer memory, because it is unreliable.

Well. All memory allocation is unreliable. And
include/linux/dma-contiguous.h even clearly states that CMA is something
to be used in cases like omapfb.

>> >Pre-allocating is possible, but that won't work if there's any need t=
o
>> >re-allocating the framebuffers. Except if the omapfb would retain and=

>> >manage the pre-allocated buffers, but that would just be more or less=

>> >the old vram allocator again.
>> >
>> >So, as I see it, the best option would be to have the standard dma_al=
loc
>> >functions get the memory for omapfb from a private pool, which is not=

>> >used for anything else.
>> >
>> >I wonder if that's possible already? It sounds quite trivial to me.
>>
>> dma_alloc functions use either CMA or (iirc) get_pages_exact if CMA is=

>> disabled. Both of those fail easily. AFAIK there are several
>> implementations with similar functionality, like CMEM and ION but
>> (correct me if I am wrong) neither of them is upstreamed. In the
>> current kernel I don't see anything that can be used for the purpose
>> of reliable allocation of big chunks of contiguous memory.
>> So, something should be done, but honestly, I can't think of anything
>> but bringing VRAM allocator back. Not that I like the idea of bringing=

>> back ~700 lines of code, but I see no other option if omapfb driver is=

>> to be actually useful.

How about the patch below? If I'm not mistaken (and I might) it reserves
separate memory area for omapfb, which is not used by CMA.

If it works, it should be extended to get the parameters via kernel
cmdline, and use that alloc only if the user requests it.


diff --git a/arch/arm/mach-omap2/common.c b/arch/arm/mach-omap2/common.c
index 2dabb9ecb986..9beecded0380 100644
--- a/arch/arm/mach-omap2/common.c
+++ b/arch/arm/mach-omap2/common.c
@@ -33,4 +33,5 @@ void __init omap_reserve(void)
 	omap_dsp_reserve_sdram_memblock();
 	omap_secure_ram_reserve_memblock();
 	omap_barrier_reserve_memblock();
+	omap_fb_reserve_memblock();
 }
diff --git a/arch/arm/mach-omap2/common.h b/arch/arm/mach-omap2/common.h
index 48e9cd34cae0..874786f05ec3 100644
--- a/arch/arm/mach-omap2/common.h
+++ b/arch/arm/mach-omap2/common.h
@@ -40,6 +40,8 @@

 #include "usb.h"

+void __init omap_fb_reserve_memblock(void);
+
 #define OMAP_INTC_START		NR_IRQS

 #if defined(CONFIG_PM) && defined(CONFIG_ARCH_OMAP2)
diff --git a/arch/arm/mach-omap2/fb.c b/arch/arm/mach-omap2/fb.c
index 26e28e94f625..8f339e88c7cd 100644
--- a/arch/arm/mach-omap2/fb.c
+++ b/arch/arm/mach-omap2/fb.c
@@ -30,9 +30,11 @@
 #include <linux/dma-mapping.h>

 #include <asm/mach/map.h>
+#include <asm/memblock.h>

 #include "soc.h"
 #include "display.h"
+#include "common.h"

 #ifdef CONFIG_OMAP2_VRFB

@@ -106,9 +108,41 @@ static struct platform_device omap_fb_device =3D {
 	.num_resources =3D 0,
 };

+static phys_addr_t omapfb_mem_base __initdata;
+static phys_addr_t omapfb_mem_size __initdata;
+
+void __init omap_fb_reserve_memblock(void)
+{
+	omapfb_mem_size =3D ALIGN(1920*1200*4*3, SZ_2M);
+	omapfb_mem_base =3D arm_memblock_steal(omapfb_mem_size, SZ_2M);
+	if (omapfb_mem_base)
+		pr_info("omapfb: reserved %u bytes at %x\n",
+			omapfb_mem_size, omapfb_mem_base);
+	else
+		pr_err("omapfb: arm_memblock_steal failed\n");
+}
+
 int __init omap_init_fb(void)
 {
-	return platform_device_register(&omap_fb_device);
+	int r;
+	int dma;
+
+	r =3D platform_device_register(&omap_fb_device);
+	if (r)
+		return r;
+
+	if (!omapfb_mem_base)
+		return 0;
+
+	dma =3D dma_declare_coherent_memory(&omap_fb_device.dev,
+		omapfb_mem_base, omapfb_mem_base,
+		omapfb_mem_size,
+		DMA_MEMORY_MAP | DMA_MEMORY_EXCLUSIVE);
+
+	if (!(dma & DMA_MEMORY_MAP))
+		pr_err("omapfb: dma_declare_coherent_memory failed\n");
+
+	return 0;
 }
 #else
 int __init omap_init_fb(void) { return 0; }



--0KsTXS7CrcCAvpLJcviKXk4BOJtP4liIh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBAgAGBQJSoGKhAAoJEPo9qoy8lh71w44QAJOCZGezTS5WniVe3lI3F9st
AHwKOQA+tCq4l8SNMqPG8o1pclO/qxaBqouQm3ScebfMP1BMKyVLBc9svILfOihJ
lfVFj9NkFgr83MkvVvSTTXsFIxH+auOVthU3kAYhmRNFbLeHw8o8uCm6bBpajgOU
p/qeCo1fZqv5fgK2XEErP/iyqU2Jx76Bu0PxDmPKcw1au5aEaNvsrgfjvBzOlxZO
yzjFwQMOgknhV8DwI4hEQuIyIijDk9CH8879vf4pXDkgiTR6n2xPGecziTYy2G8t
QSVe6S3jxk8Np3+fbneie0OvwS78j1tReTJq6Y1MYQoYFvT3uR6wBHvoceOE1J45
ZHhIydKaDDOIcEAmNk3sVAWOXLLCJNSGcUCtyurT4DoFhSvjZwbHis0RqCD7+Ckm
jBAlp1lpxDlvjkOQbkuvR9palvd3AuVjSW7gGyOwe92/zMRKX8cTOY0BkW6zUpYV
I7+T7oLR8MIrANCzYIGZ2Y1Sxk8LJ16yN+r1Lv5s9zUtBsiAUeNn4SzDmGlSOAva
Ht1s1SQ01PH0nw5RTOcYb+kMgnOjm1+EfzzxdAyF8yCi1f8w0MzhcHMS3tFaWsaK
4vJ3yW016M65woKpwK8cEhqaNbXBIT1ZWJaHz3/eYiCHo7NIE/vmpvCwGFiUHLq1
/+Ex8auNrZC80GimOtIh
=gOsJ
-----END PGP SIGNATURE-----

--0KsTXS7CrcCAvpLJcviKXk4BOJtP4liIh--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
