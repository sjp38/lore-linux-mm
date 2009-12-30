Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1BF9B60021B
	for <linux-mm@kvack.org>; Wed, 30 Dec 2009 01:21:45 -0500 (EST)
Received: by iwn41 with SMTP id 41so8011677iwn.12
        for <linux-mm@kvack.org>; Tue, 29 Dec 2009 22:21:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LFD.2.00.0912291435070.14938@localhost.localdomain>
References: <20091229094202.25818e9b@nehalam>
	 <alpine.LFD.2.00.0912291435070.14938@localhost.localdomain>
Date: Wed, 30 Dec 2009 15:21:43 +0900
Message-ID: <2f11576a0912292221r7ba59e9dw431c7b43b578a04@mail.gmail.com>
Subject: Re: ACPI warning from alloc_pages_nodemask on boot (2.6.33
	regression)
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Len Brown <lenb@kernel.org>
Cc: Stephen Hemminger <shemminger@vyatta.com>, linux-acpi@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> [ =A0 =A01.611664] ACPI Warning: Incorrect checksum in table [OEMB] - 94=
, should be 8C (20091214/tbutils-314)
>> [ =A0 =A01.611698] ACPI: SSDT 00000000bf7980c0 00403 (v01 DpgPmm =A0P001=
Ist 00000011 INTL 20060113)
>> [ =A0 =A01.613966] ACPI: SSDT 00000000bf7984d0 00403 (v01 DpgPmm =A0P002=
Ist 00000012 INTL 20060113)
>> [ =A0 =A01.616242] ACPI: SSDT 00000000bf7988e0 00403 (v01 DpgPmm =A0P003=
Ist 00000012 INTL 20060113)
>> [ =A0 =A01.618526] ACPI: SSDT 00000000bf798cf0 00403 (v01 DpgPmm =A0P004=
Ist 00000012 INTL 20060113)
>> [ =A0 =A01.620817] ACPI: SSDT 00000000bf799100 00403 (v01 DpgPmm =A0P005=
Ist 00000012 INTL 20060113)
>> [ =A0 =A01.623112] ACPI: SSDT 00000000bf799510 00403 (v01 DpgPmm =A0P006=
Ist 00000012 INTL 20060113)
>> [ =A0 =A01.625409] ACPI: SSDT 00000000bf799920 00403 (v01 DpgPmm =A0P007=
Ist 00000012 INTL 20060113)
>> [ =A0 =A01.627734] ACPI: SSDT 00000000bf799d30 00403 (v01 DpgPmm =A0P008=
Ist 00000012 INTL 20060113)
>> [ =A0 =A01.630020] ------------[ cut here ]------------
>> [ =A0 =A01.630026] WARNING: at mm/page_alloc.c:1812 __alloc_pages_nodema=
sk+0x617/0x730()
>
> =A0 =A0 =A0 =A0if (order >=3D MAX_ORDER) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0WARN_ON_ONCE(!(gfp_mask & __GFP_NOWARN));
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NULL;
> =A0 =A0 =A0 =A0}
>
> I don't know what the mm alloc code is complaining about here.

first, exceeding MAX_ORDER makes to return NULL since linux 1.x. then
alloc_pages(MAX_ORDER) is wrong usage generally,
but we hope to allow following usage:

    page =3D alloc_pages(__GFP_nowarn, big-order)
    if (!page)
        page =3D alloc_pages(small-order)

It is the reason of __GFP_NOWARN check.
I guess ACPI don't need large `contenious' memory.


>
>> [ =A0 =A01.630028] Hardware name: System Product Name
>> [ =A0 =A01.630029] Modules linked in:
>> [ =A0 =A01.630032] Pid: 1, comm: swapper Not tainted 2.6.33-rc2 #4
>> [ =A0 =A01.630034] Call Trace:
>> [ =A0 =A01.630038] =A0[<ffffffff810532a8>] warn_slowpath_common+0x78/0xb=
0
>> [ =A0 =A01.630041] =A0[<ffffffff810532ef>] warn_slowpath_null+0xf/0x20
>> [ =A0 =A01.630044] =A0[<ffffffff810e65a7>] __alloc_pages_nodemask+0x617/=
0x730
>> [ =A0 =A01.630048] =A0[<ffffffff81114d14>] alloc_page_interleave+0x34/0x=
90
>> [ =A0 =A01.630050] =A0[<ffffffff81115444>] alloc_pages_current+0xc4/0xd0
>> [ =A0 =A01.630053] =A0[<ffffffff810e5549>] __get_free_pages+0x9/0x50
>> [ =A0 =A01.630055] =A0[<ffffffff8111ef3b>] __kmalloc+0x1bb/0x1f0
>> [ =A0 =A01.630059] =A0[<ffffffff81089bdd>] ? trace_hardirqs_on+0xd/0x10
>> [ =A0 =A01.630064] =A0[<ffffffff812cae3e>] acpi_os_allocate+0x25/0x27
>> [ =A0 =A01.630067] =A0[<ffffffff812cafab>] acpi_ex_load_op+0xd8/0x260
>> [ =A0 =A01.630070] =A0[<ffffffff812cd89e>] acpi_ex_opcode_1A_1T_0R+0x25/=
0x4b
>> [ =A0 =A01.630073] =A0[<ffffffff812c5008>] acpi_ds_exec_end_op+0xea/0x3d=
6
>> [ =A0 =A01.630076] =A0[<ffffffff812d7532>] acpi_ps_parse_loop+0x7d9/0x95=
f
>> [ =A0 =A01.630079] =A0[<ffffffff812c58cf>] ? acpi_ds_call_control_method=
+0x166/0x1d7
>> [ =A0 =A01.630082] =A0[<ffffffff812d6641>] acpi_ps_parse_aml+0x9a/0x2b9
>> [ =A0 =A01.630085] =A0[<ffffffff812d7d3a>] acpi_ps_execute_method+0x1c8/=
0x29a
>> [ =A0 =A01.630088] =A0[<ffffffff812d2f4d>] acpi_ns_evaluate+0xe1/0x1a8
>> [ =A0 =A01.630090] =A0[<ffffffff812d29a1>] acpi_evaluate_object+0xf9/0x1=
f2
>> [ =A0 =A01.630094] =A0[<ffffffff812bda07>] acpi_processor_set_pdc+0x1be/=
0x1e8
>> [ =A0 =A01.630097] =A0[<ffffffff812bda3a>] early_init_pdc+0x9/0xf
>> [ =A0 =A01.630100] =A0[<ffffffff812d4a96>] acpi_ns_walk_namespace+0xb9/0=
x187
>> [ =A0 =A01.630102] =A0[<ffffffff812bda31>] ? early_init_pdc+0x0/0xf
>> [ =A0 =A01.630105] =A0[<ffffffff812bda31>] ? early_init_pdc+0x0/0xf
>> [ =A0 =A01.630108] =A0[<ffffffff812d27e0>] acpi_walk_namespace+0x85/0xbf
>> [ =A0 =A01.630111] =A0[<ffffffff81cc7da9>] ? acpi_init+0x0/0x12f
>> [ =A0 =A01.630113] =A0[<ffffffff81cc7da9>] ? acpi_init+0x0/0x12f
>> [ =A0 =A01.630116] =A0[<ffffffff812bd7c6>] acpi_early_processor_set_pdc+=
0x3a/0x3c
>> [ =A0 =A01.630119] =A0[<ffffffff81cc7c80>] acpi_bus_init+0xb5/0x1de
>> [ =A0 =A01.630123] =A0[<ffffffff8128239e>] ? kobject_create_and_add+0x3e=
/0x80
>> [ =A0 =A01.630126] =A0[<ffffffff81cc2f0c>] ? genhd_device_init+0x0/0x7b
>> [ =A0 =A01.630128] =A0[<ffffffff81cc7da9>] ? acpi_init+0x0/0x12f
>> [ =A0 =A01.630131] =A0[<ffffffff81cc7e1a>] acpi_init+0x71/0x12f
>> [ =A0 =A01.630134] =A0[<ffffffff81002047>] do_one_initcall+0x37/0x1a0
>> [ =A0 =A01.630137] =A0[<ffffffff81ca1731>] kernel_init+0x166/0x1bc
>> [ =A0 =A01.630140] =A0[<ffffffff8100a3e4>] kernel_thread_helper+0x4/0x10
>> [ =A0 =A01.630144] =A0[<ffffffff814f95d0>] ? restore_args+0x0/0x30
>> [ =A0 =A01.630147] =A0[<ffffffff81ca15cb>] ? kernel_init+0x0/0x1bc
>> [ =A0 =A01.630149] =A0[<ffffffff8100a3e0>] ? kernel_thread_helper+0x0/0x=
10
>> [ =A0 =A01.630156] ---[ end trace f17e946d22a56015 ]---
>> [ =A0 =A01.630159] ACPI Error (psparse-0537): Method parse/execution fai=
led [\_PR_.P009._OSC] (Node ffff8801b9069c20), AE_NO_MEMORY
>> [ =A0 =A01.630196] ACPI Error (psparse-0537): Method parse/execution fai=
led [\_PR_.P009._PDC] (Node ffff8801b9069c00), AE_NO_MEMORY
>
> We've changed both the _OSC and _PDC code in this release.
> In particular, _PDC is being evaluated earler than last release
> in an attempt to be more Windows compatible...
>
> Stephen,
> Please attach the output from acpidump to a new bugzilla entry
> and point this thread to it.
>
> thanks,
> Len Brown, Intel Open Source Technology Center
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
