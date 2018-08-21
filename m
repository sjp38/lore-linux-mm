Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E08976B1E02
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 05:38:00 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id w44-v6so1734284edb.16
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 02:38:00 -0700 (PDT)
Received: from mx1.molgen.mpg.de (mx3.molgen.mpg.de. [141.14.17.11])
        by mx.google.com with ESMTPS id x48-v6si1574935edd.165.2018.08.21.02.37.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Aug 2018 02:37:58 -0700 (PDT)
Subject: Re: How to profile 160 ms spent in
 `add_highpages_with_active_regions()`?
References: <d5a65984-36a7-15d8-b04a-461d0f53d36d@molgen.mpg.de>
From: Paul Menzel <pmenzel+linux-mm@molgen.mpg.de>
Message-ID: <5e5a39f4-1b91-c877-1368-0946160ef4be@molgen.mpg.de>
Date: Tue, 21 Aug 2018 11:37:57 +0200
MIME-Version: 1.0
In-Reply-To: <d5a65984-36a7-15d8-b04a-461d0f53d36d@molgen.mpg.de>
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha-256; boundary="------------ms000506030105090405080509"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>

This is a cryptographically signed message in MIME format.

--------------ms000506030105090405080509
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable

[Removed non-working Pavel Tatashin <pasha.tatashin@oracle.com>]

Dear Linux folks,


On 08/17/18 10:12, Paul Menzel wrote:

> With the merge of branch 'x86-timers-for-linus'
> of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip early time
> stamps are now printed.
>=20
>> Early TSC based time stamping to allow better boot time analysis.
>> =C2=A0=C2=A0=C2=A0 This comes with a general cleanup of the TSC calibr=
ation code which
>> grew warts and duct taping over the years and removes 250 lines of
>> code. Initiated and mostly implemented by Pavel with help from various=

>> folks
>=20
> Looking at those early time stamps, in this case on an ASRock E350M1,
> there is a 160 ms delay in the code below.
>=20
> Before:
>=20
> ```
> [=C2=A0=C2=A0=C2=A0 0.000000] Initializing CPU#0
> [=C2=A0=C2=A0=C2=A0 0.000000] Initializing HighMem for node 0 (000373fe=
:000c7d3c)
> [=C2=A0=C2=A0=C2=A0 0.000000] Initializing Movable for node 0 (00000000=
:00000000)
> [=C2=A0=C2=A0=C2=A0 0.000000] Memory: 3225668K/3273580K available (8898=
K kernel code, 747K rwdata, 2808K rodata, 768K init, 628K bss, 47912K res=
erved, 0K cma-reserved, 2368760K highmem)
> ```
>=20
> After:
>=20
> ```
> [=C2=A0=C2=A0=C2=A0 0.063473] Initializing CPU#0
> [=C2=A0=C2=A0=C2=A0 0.063484] Initializing HighMem for node 0 (00036ffe=
:000c7d3c)
> [=C2=A0=C2=A0=C2=A0 0.229442] Initializing Movable for node 0 (00000000=
:00000000)
> [=C2=A0=C2=A0=C2=A0 0.236020] Memory: 3225728K/3273580K available (8966=
K kernel code, 750K rwdata, 2828K rodata, 776K init, 640K bss, 47852K res=
erved, 0K cma-reserved, 2372856K highmem)
> ```
>=20
> The code in question is from `arch/x86/mm/highmem_32.c`.
>=20
>> void __init set_highmem_pages_init(void)
>> {
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 struct zone *zone;
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 int nid;
>>
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 /*
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 * Explicitly reset zo=
ne->managed_pages because set_highmem_pages_init()
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 * is invoked before f=
ree_all_bootmem()
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 */
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 reset_all_zones_managed_pag=
es();
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 for_each_zone(zone) {
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 unsigned long zone_start_pfn, zone_end_pfn;
>>
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 if (!is_highmem(zone))
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 contin=
ue;
>>
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 zone_start_pfn =3D zone->zone_start_pfn;
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 zone_end_pfn =3D zone_start_pfn + zone->spanned_pages;=

>>
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 nid =3D zone_to_nid(zone);
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 printk(KERN_INFO "Initializing %s for node %d (%08lx:%=
08lx)\n",
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 zone->name, nid, zone_start_pfn, =
zone_end_pfn);
>>
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 add_highpages_with_active_regions(nid, zone_start_pfn,=

>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 zone_end_pfn);
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 }
>> }
>=20
> And in there, it seems to be the function below.
>=20
>> void __init add_highpages_with_active_regions(int nid,
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =
unsigned long start_pfn, unsigned long end_pfn)
>> {
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 phys_addr_t start, end;
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 u64 i;
>>
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 for_each_free_mem_range(i, =
nid, MEMBLOCK_NONE, &start, &end, NULL) {
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 unsigned long pfn =3D clamp_t(unsigned long, PFN_UP(st=
art),
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 start_pfn, end_pfn);
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 unsigned long e_pfn =3D clamp_t(unsigned long, PFN_DOW=
N(end),
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 start_pfn, end_pfn);
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 for ( ; pfn < e_pfn; pfn++)
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (pf=
n_valid(pfn))
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 free_highmem_page(pfn_to_page(pfn=
));
>=20
> Assuming the time stamps are correct, how can a profile that delay
> without adding print statements all over the place? Using ftrace
> doesn=E2=80=99t seem to work for me, probably because it=E2=80=99s that=
 early.

I added print statements, and got the result below.

```
[    0.057109] Initializing CPU#0
[    0.057119] Initializing HighMem for node 0 (00036ffe:000c7d3c)
[    0.057122] add_highpages_with_active_regions: for_each_free_mem_range=
: i =3D 0
[    0.057124] add_highpages_with_active_regions: after for loop
[    0.057126] add_highpages_with_active_regions: for_each_free_mem_range=
: i =3D 1
[    0.057127] add_highpages_with_active_regions: after for loop
[    0.057128] add_highpages_with_active_regions: for_each_free_mem_range=
: i =3D 1
[    0.057129] add_highpages_with_active_regions: after for loop
[    0.057131] add_highpages_with_active_regions: for_each_free_mem_range=
: i =3D 1
[    0.057132] add_highpages_with_active_regions: after for loop
[    0.057133] add_highpages_with_active_regions: for_each_free_mem_range=
: i =3D 1
[    0.057134] add_highpages_with_active_regions: after for loop
[    0.057136] add_highpages_with_active_regions: for_each_free_mem_range=
: i =3D 1
[    0.057137] add_highpages_with_active_regions: after for loop
[    0.057138] add_highpages_with_active_regions: for_each_free_mem_range=
: i =3D 1
[    0.057140] add_highpages_with_active_regions: after for loop
[    0.057141] add_highpages_with_active_regions: for_each_free_mem_range=
: i =3D 1
[    0.057142] add_highpages_with_active_regions: after for loop
[    0.057143] add_highpages_with_active_regions: for_each_free_mem_range=
: i =3D 1
[    0.057145] add_highpages_with_active_regions: after for loop
[    0.057146] add_highpages_with_active_regions: for_each_free_mem_range=
: i =3D 1
[    0.057147] add_highpages_with_active_regions: after for loop
[    0.057149] add_highpages_with_active_regions: for_each_free_mem_range=
: i =3D 1
[    0.057150] add_highpages_with_active_regions: after for loop
[    0.057151] add_highpages_with_active_regions: for_each_free_mem_range=
: i =3D 1
[    0.057152] add_highpages_with_active_regions: after for loop
[    0.057154] add_highpages_with_active_regions: for_each_free_mem_range=
: i =3D 1
[    0.057155] add_highpages_with_active_regions: after for loop
[    0.057156] add_highpages_with_active_regions: for_each_free_mem_range=
: i =3D 1
[    0.057157] add_highpages_with_active_regions: after for loop
[    0.057159] add_highpages_with_active_regions: for_each_free_mem_range=
: i =3D 1
[    0.057160] add_highpages_with_active_regions: after for loop
[    0.057161] add_highpages_with_active_regions: for_each_free_mem_range=
: i =3D 1
[    0.057163] add_highpages_with_active_regions: after for loop
[    0.057164] add_highpages_with_active_regions: for_each_free_mem_range=
: i =3D 1
[    0.057165] add_highpages_with_active_regions: after for loop
[    0.057167] add_highpages_with_active_regions: for_each_free_mem_range=
: i =3D 2
[    0.222580] add_highpages_with_active_regions: after for loop
[    0.222583] Initializing Movable for node 0 (00000000:00000000)
[    0.222585] add_highpages_with_active_regions: for_each_free_mem_range=
: i =3D 0
[    0.222587] add_highpages_with_active_regions: after for loop
[    0.222588] add_highpages_with_active_regions: for_each_free_mem_range=
: i =3D 1
[    0.222589] add_highpages_with_active_regions: after for loop
[    0.222591] add_highpages_with_active_regions: for_each_free_mem_range=
: i =3D 1
[    0.222592] add_highpages_with_active_regions: after for loop
[    0.222593] add_highpages_with_active_regions: for_each_free_mem_range=
: i =3D 1
[    0.222595] add_highpages_with_active_regions: after for loop
[    0.222596] add_highpages_with_active_regions: for_each_free_mem_range=
: i =3D 1
[    0.222597] add_highpages_with_active_regions: after for loop
[    0.222599] add_highpages_with_active_regions: for_each_free_mem_range=
: i =3D 1
[    0.222600] add_highpages_with_active_regions: after for loop
[    0.222601] add_highpages_with_active_regions: for_each_free_mem_range=
: i =3D 1
[    0.222602] add_highpages_with_active_regions: after for loop
[    0.222604] add_highpages_with_active_regions: for_each_free_mem_range=
: i =3D 1
[    0.222605] add_highpages_with_active_regions: after for loop
[    0.222606] add_highpages_with_active_regions: for_each_free_mem_range=
: i =3D 1
[    0.222607] add_highpages_with_active_regions: after for loop
[    0.222609] add_highpages_with_active_regions: for_each_free_mem_range=
: i =3D 1
[    0.222610] add_highpages_with_active_regions: after for loop
[    0.222611] add_highpages_with_active_regions: for_each_free_mem_range=
: i =3D 1
[    0.222613] add_highpages_with_active_regions: after for loop
[    0.222614] add_highpages_with_active_regions: for_each_free_mem_range=
: i =3D 1
[    0.222615] add_highpages_with_active_regions: after for loop
[    0.222616] add_highpages_with_active_regions: for_each_free_mem_range=
: i =3D 1
[    0.222618] add_highpages_with_active_regions: after for loop
[    0.222619] add_highpages_with_active_regions: for_each_free_mem_range=
: i =3D 1
[    0.222620] add_highpages_with_active_regions: after for loop
[    0.222622] add_highpages_with_active_regions: for_each_free_mem_range=
: i =3D 1
[    0.222623] add_highpages_with_active_regions: after for loop
[    0.222624] add_highpages_with_active_regions: for_each_free_mem_range=
: i =3D 1
[    0.222625] add_highpages_with_active_regions: after for loop
[    0.222627] add_highpages_with_active_regions: for_each_free_mem_range=
: i =3D 1
[    0.222628] add_highpages_with_active_regions: after for loop
[    0.222629] add_highpages_with_active_regions: for_each_free_mem_range=
: i =3D 2
[    0.222630] add_highpages_with_active_regions: after for loop
```

So, the problem is with i =3D 2.


Kind regards,

Paul


--------------ms000506030105090405080509
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExDzANBglghkgBZQMEAgEFADCABgkqhkiG9w0BBwEAAKCC
EFowggUSMIID+qADAgECAgkA4wvV+K8l2YEwDQYJKoZIhvcNAQELBQAwgYIxCzAJBgNVBAYT
AkRFMSswKQYDVQQKDCJULVN5c3RlbXMgRW50ZXJwcmlzZSBTZXJ2aWNlcyBHbWJIMR8wHQYD
VQQLDBZULVN5c3RlbXMgVHJ1c3QgQ2VudGVyMSUwIwYDVQQDDBxULVRlbGVTZWMgR2xvYmFs
Um9vdCBDbGFzcyAyMB4XDTE2MDIyMjEzMzgyMloXDTMxMDIyMjIzNTk1OVowgZUxCzAJBgNV
BAYTAkRFMUUwQwYDVQQKEzxWZXJlaW4genVyIEZvZXJkZXJ1bmcgZWluZXMgRGV1dHNjaGVu
IEZvcnNjaHVuZ3NuZXR6ZXMgZS4gVi4xEDAOBgNVBAsTB0RGTi1QS0kxLTArBgNVBAMTJERG
Ti1WZXJlaW4gQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkgMjCCASIwDQYJKoZIhvcNAQEBBQAD
ggEPADCCAQoCggEBAMtg1/9moUHN0vqHl4pzq5lN6mc5WqFggEcVToyVsuXPztNXS43O+FZs
FVV2B+pG/cgDRWM+cNSrVICxI5y+NyipCf8FXRgPxJiZN7Mg9mZ4F4fCnQ7MSjLnFp2uDo0p
eQcAIFTcFV9Kltd4tjTTwXS1nem/wHdN6r1ZB+BaL2w8pQDcNb1lDY9/Mm3yWmpLYgHurDg0
WUU2SQXaeMpqbVvAgWsRzNI8qIv4cRrKO+KA3Ra0Z3qLNupOkSk9s1FcragMvp0049ENF4N1
xDkesJQLEvHVaY4l9Lg9K7/AjsMeO6W/VRCrKq4Xl14zzsjz9AkH4wKGMUZrAcUQDBHHWekC
AwEAAaOCAXQwggFwMA4GA1UdDwEB/wQEAwIBBjAdBgNVHQ4EFgQUk+PYMiba1fFKpZFK4OpL
4qIMz+EwHwYDVR0jBBgwFoAUv1kgNgB5oKAia4zV8mHSuCzLgkowEgYDVR0TAQH/BAgwBgEB
/wIBAjAzBgNVHSAELDAqMA8GDSsGAQQBga0hgiwBAQQwDQYLKwYBBAGBrSGCLB4wCAYGZ4EM
AQICMEwGA1UdHwRFMEMwQaA/oD2GO2h0dHA6Ly9wa2kwMzM2LnRlbGVzZWMuZGUvcmwvVGVs
ZVNlY19HbG9iYWxSb290X0NsYXNzXzIuY3JsMIGGBggrBgEFBQcBAQR6MHgwLAYIKwYBBQUH
MAGGIGh0dHA6Ly9vY3NwMDMzNi50ZWxlc2VjLmRlL29jc3ByMEgGCCsGAQUFBzAChjxodHRw
Oi8vcGtpMDMzNi50ZWxlc2VjLmRlL2NydC9UZWxlU2VjX0dsb2JhbFJvb3RfQ2xhc3NfMi5j
ZXIwDQYJKoZIhvcNAQELBQADggEBAIcL/z4Cm2XIVi3WO5qYi3FP2ropqiH5Ri71sqQPrhE4
eTizDnS6dl2e6BiClmLbTDPo3flq3zK9LExHYFV/53RrtCyD2HlrtrdNUAtmB7Xts5et6u5/
MOaZ/SLick0+hFvu+c+Z6n/XUjkurJgARH5pO7917tALOxrN5fcPImxHhPalR6D90Bo0fa3S
PXez7vTXTf/D6OWST1k+kEcQSrCFWMBvf/iu7QhCnh7U3xQuTY+8npTD5+32GPg8SecmqKc2
2CzeIs2LgtjZeOJVEqM7h0S2EQvVDFKvaYwPBt/QolOLV5h7z/0HJPT8vcP9SpIClxvyt7bP
ZYoaorVyGTkwggWNMIIEdaADAgECAgwcOtRQhH7u81j4jncwDQYJKoZIhvcNAQELBQAwgZUx
CzAJBgNVBAYTAkRFMUUwQwYDVQQKEzxWZXJlaW4genVyIEZvZXJkZXJ1bmcgZWluZXMgRGV1
dHNjaGVuIEZvcnNjaHVuZ3NuZXR6ZXMgZS4gVi4xEDAOBgNVBAsTB0RGTi1QS0kxLTArBgNV
BAMTJERGTi1WZXJlaW4gQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkgMjAeFw0xNjExMDMxNTI0
NDhaFw0zMTAyMjIyMzU5NTlaMGoxCzAJBgNVBAYTAkRFMQ8wDQYDVQQIDAZCYXllcm4xETAP
BgNVBAcMCE11ZW5jaGVuMSAwHgYDVQQKDBdNYXgtUGxhbmNrLUdlc2VsbHNjaGFmdDEVMBMG
A1UEAwwMTVBHIENBIC0gRzAyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnhx4
59Lh4WqgOs/Md04XxU2yFtfM15ZuJV0PZP7BmqSJKLLPyqmOrADfNdJ5PIGBto2JBhtRRBHd
G0GROOvTRHjzOga95WOTeura79T21FWwwAwa29OFnD3ZplQs6HgdwQrZWNi1WHNJxn/4mA19
rNEBUc5urSIpZPvZi5XmlF3v3JHOlx3KWV7mUteB4pwEEfGTg4npPAJbp2o7arxQdoIq+Pu2
OsvqhD7Rk4QeaX+EM1QS4lqd1otW4hE70h/ODPy1xffgbZiuotWQLC6nIwa65Qv6byqlIX0q
Zuu99Vsu+r3sWYsL5SBkgecNI7fMJ5tfHrjoxfrKl/ErTAt8GQIDAQABo4ICBTCCAgEwEgYD
VR0TAQH/BAgwBgEB/wIBATAOBgNVHQ8BAf8EBAMCAQYwKQYDVR0gBCIwIDANBgsrBgEEAYGt
IYIsHjAPBg0rBgEEAYGtIYIsAQEEMB0GA1UdDgQWBBTEiKUH7rh7qgwTv9opdGNSG0lwFjAf
BgNVHSMEGDAWgBST49gyJtrV8UqlkUrg6kviogzP4TCBjwYDVR0fBIGHMIGEMECgPqA8hjpo
dHRwOi8vY2RwMS5wY2EuZGZuLmRlL2dsb2JhbC1yb290LWcyLWNhL3B1Yi9jcmwvY2Fjcmwu
Y3JsMECgPqA8hjpodHRwOi8vY2RwMi5wY2EuZGZuLmRlL2dsb2JhbC1yb290LWcyLWNhL3B1
Yi9jcmwvY2FjcmwuY3JsMIHdBggrBgEFBQcBAQSB0DCBzTAzBggrBgEFBQcwAYYnaHR0cDov
L29jc3AucGNhLmRmbi5kZS9PQ1NQLVNlcnZlci9PQ1NQMEoGCCsGAQUFBzAChj5odHRwOi8v
Y2RwMS5wY2EuZGZuLmRlL2dsb2JhbC1yb290LWcyLWNhL3B1Yi9jYWNlcnQvY2FjZXJ0LmNy
dDBKBggrBgEFBQcwAoY+aHR0cDovL2NkcDIucGNhLmRmbi5kZS9nbG9iYWwtcm9vdC1nMi1j
YS9wdWIvY2FjZXJ0L2NhY2VydC5jcnQwDQYJKoZIhvcNAQELBQADggEBABLpeD5FygzqOjj+
/lAOy20UQOGWlx0RMuPcI4nuyFT8SGmK9lD7QCg/HoaJlfU/r78ex+SEide326evlFAoJXIF
jVyzNltDhpMKrPIDuh2N12zyn1EtagqPL6hu4pVRzcBpl/F2HCvtmMx5K4WN1L1fmHWLcSap
dhXLvAZ9RG/B3rqyULLSNN8xHXYXpmtvG0VGJAndZ+lj+BH7uvd3nHWnXEHC2q7iQlDUqg0a
wIqWJgdLlx1Q8Dg/sodv0m+LN0kOzGvVDRCmowBdWGhhusD+duKV66pBl+qhC+4LipariWaM
qK5ppMQROATjYeNRvwI+nDcEXr2vDaKmdbxgDVwwggWvMIIEl6ADAgECAgweKlJIhfynPMVG
/KIwDQYJKoZIhvcNAQELBQAwajELMAkGA1UEBhMCREUxDzANBgNVBAgMBkJheWVybjERMA8G
A1UEBwwITXVlbmNoZW4xIDAeBgNVBAoMF01heC1QbGFuY2stR2VzZWxsc2NoYWZ0MRUwEwYD
VQQDDAxNUEcgQ0EgLSBHMDIwHhcNMTcxMTE0MTEzNDE2WhcNMjAxMTEzMTEzNDE2WjCBizEL
MAkGA1UEBhMCREUxIDAeBgNVBAoMF01heC1QbGFuY2stR2VzZWxsc2NoYWZ0MTQwMgYDVQQL
DCtNYXgtUGxhbmNrLUluc3RpdHV0IGZ1ZXIgbW9sZWt1bGFyZSBHZW5ldGlrMQ4wDAYDVQQL
DAVNUElNRzEUMBIGA1UEAwwLUGF1bCBNZW56ZWwwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAw
ggEKAoIBAQDIh/UR/AX/YQ48VWWDMLTYtXjYJyhRHMc81ZHMMoaoG66lWB9MtKRTnB5lovLZ
enTIUyPsCrMhTqV9CWzDf6v9gOTWVxHEYqrUwK5H1gx4XoK81nfV8oGV4EKuVmmikTXiztGz
peyDmOY8o/EFNWP7YuRkY/lPQJQBeBHYq9AYIgX4StuXu83nusq4MDydygVOeZC15ts0tv3/
6WmibmZd1OZRqxDOkoBbY3Djx6lERohs3IKS6RKiI7e90rCSy9rtidJBOvaQS9wvtOSKPx0a
+2pAgJEVzZFjOAfBcXydXtqXhcpOi2VCyl+7+LnnTz016JJLsCBuWEcB3kP9nJYNAgMBAAGj
ggIxMIICLTAJBgNVHRMEAjAAMA4GA1UdDwEB/wQEAwIF4DAdBgNVHSUEFjAUBggrBgEFBQcD
AgYIKwYBBQUHAwQwHQYDVR0OBBYEFHM0Mc3XjMLlhWpp4JufRELL4A/qMB8GA1UdIwQYMBaA
FMSIpQfuuHuqDBO/2il0Y1IbSXAWMCAGA1UdEQQZMBeBFXBtZW56ZWxAbW9sZ2VuLm1wZy5k
ZTB9BgNVHR8EdjB0MDigNqA0hjJodHRwOi8vY2RwMS5wY2EuZGZuLmRlL21wZy1nMi1jYS9w
dWIvY3JsL2NhY3JsLmNybDA4oDagNIYyaHR0cDovL2NkcDIucGNhLmRmbi5kZS9tcGctZzIt
Y2EvcHViL2NybC9jYWNybC5jcmwwgc0GCCsGAQUFBwEBBIHAMIG9MDMGCCsGAQUFBzABhido
dHRwOi8vb2NzcC5wY2EuZGZuLmRlL09DU1AtU2VydmVyL09DU1AwQgYIKwYBBQUHMAKGNmh0
dHA6Ly9jZHAxLnBjYS5kZm4uZGUvbXBnLWcyLWNhL3B1Yi9jYWNlcnQvY2FjZXJ0LmNydDBC
BggrBgEFBQcwAoY2aHR0cDovL2NkcDIucGNhLmRmbi5kZS9tcGctZzItY2EvcHViL2NhY2Vy
dC9jYWNlcnQuY3J0MEAGA1UdIAQ5MDcwDwYNKwYBBAGBrSGCLAEBBDARBg8rBgEEAYGtIYIs
AQEEAwYwEQYPKwYBBAGBrSGCLAIBBAMGMA0GCSqGSIb3DQEBCwUAA4IBAQCQs6bUDROpFO2F
Qz2FMgrdb39VEo8P3DhmpqkaIMC5ZurGbbAL/tAR6lpe4af682nEOJ7VW86ilsIJgm1j0ueY
aOuL8jrN4X7IF/8KdZnnNnImW3QVni6TCcc+7+ggci9JHtt0IDCj5vPJBpP/dKXLCN4M+exl
GXYpfHgxh8gclJPY1rquhQrihCzHfKB01w9h9tWZDVMtSoy9EUJFhCXw7mYUsvBeJwZesN2B
fndPkrXx6XWDdU3S1LyKgHlLIFtarLFm2Hb5zAUR33h+26cN6ohcGqGEEzgIG8tXS8gztEaj
1s2RyzmKd4SXTkKR3GhkZNVWy+gM68J7jP6zzN+cMYIDmjCCA5YCAQEwejBqMQswCQYDVQQG
EwJERTEPMA0GA1UECAwGQmF5ZXJuMREwDwYDVQQHDAhNdWVuY2hlbjEgMB4GA1UECgwXTWF4
LVBsYW5jay1HZXNlbGxzY2hhZnQxFTATBgNVBAMMDE1QRyBDQSAtIEcwMgIMHipSSIX8pzzF
RvyiMA0GCWCGSAFlAwQCAQUAoIIB8TAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqG
SIb3DQEJBTEPFw0xODA4MjEwOTM3NTdaMC8GCSqGSIb3DQEJBDEiBCAJVJjbV1/5WQKMnwoC
CULJVaZdnLc7X4M9WsKrYI2LPDBsBgkqhkiG9w0BCQ8xXzBdMAsGCWCGSAFlAwQBKjALBglg
hkgBZQMEAQIwCgYIKoZIhvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqGSIb3DQMCAgFAMAcG
BSsOAwIHMA0GCCqGSIb3DQMCAgEoMIGJBgkrBgEEAYI3EAQxfDB6MGoxCzAJBgNVBAYTAkRF
MQ8wDQYDVQQIDAZCYXllcm4xETAPBgNVBAcMCE11ZW5jaGVuMSAwHgYDVQQKDBdNYXgtUGxh
bmNrLUdlc2VsbHNjaGFmdDEVMBMGA1UEAwwMTVBHIENBIC0gRzAyAgweKlJIhfynPMVG/KIw
gYsGCyqGSIb3DQEJEAILMXygejBqMQswCQYDVQQGEwJERTEPMA0GA1UECAwGQmF5ZXJuMREw
DwYDVQQHDAhNdWVuY2hlbjEgMB4GA1UECgwXTWF4LVBsYW5jay1HZXNlbGxzY2hhZnQxFTAT
BgNVBAMMDE1QRyBDQSAtIEcwMgIMHipSSIX8pzzFRvyiMA0GCSqGSIb3DQEBAQUABIIBAIEL
155AOlgUWzn8z8ln70/UQocFbIf7dEEpVr46FkbUoaREGuCgClTDGt/A7qIk6PzHHKKxQTxM
UOPRvA1LzRymBt8YdY1uclYDjU27sk55WJHdrjDxJwuVXn9KPvTB6RVCq9nSeFc93PCIyvFB
tZuTPkRudpvBVBUXmmgIZps3axoQjsvX9Kyfuwnpp4YPOhz4YQtIY3pfvmemcFdlHQdwQOiA
gYiI0SerEtcr0jIHksjRAq3LU7kt6Qetju+voh8SoNCXqE9+p61xZFwRD9TIqBqVCvrKjW38
8Z7xZMzAQ6umC2QWZPPOnmwoBjeuprP2eVIn6EcoWdUacJM0kzsAAAAAAAA=
--------------ms000506030105090405080509--
