Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6ECD06B0089
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 13:24:29 -0500 (EST)
Received: by pxi7 with SMTP id 7so65102pxi.8
        for <linux-mm@kvack.org>; Tue, 07 Dec 2010 10:24:27 -0800 (PST)
Date: Tue, 7 Dec 2010 11:24:20 -0700
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [1/7,v8] NUMA Hotplug Emulator: documentation
Message-ID: <20101207182420.GA2038@mgebm.net>
References: <20101207010033.280301752@intel.com>
 <20101207010139.681125359@intel.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="C7zPtVaVf+AK4Oqc"
Content-Disposition: inline
In-Reply-To: <20101207010139.681125359@intel.com>
Sender: owner-linux-mm@kvack.org
To: shaohui.zheng@intel.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, rientjes@google.com, dave@linux.vnet.ibm.com, gregkh@suse.de, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>


--C7zPtVaVf+AK4Oqc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Shaohui,

The documentation patch seems to be stale, it needs to be updated to match =
the
new file names.

On Tue, 07 Dec 2010, shaohui.zheng@intel.com wrote:

> From: Shaohui Zheng <shaohui.zheng@intel.com>
>=20
> add a text file Documentation/x86/x86_64/numa_hotplug_emulator.txt
> to explain the usage for the hotplug emulator.
>=20
> Reviewed-By: Randy Dunlap <randy.dunlap@oracle.com>
> Signed-off-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Haicheng Li <haicheng.li@intel.com>
> Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
> ---
> Index: linux-hpe4/Documentation/x86/x86_64/numa_hotplug_emulator.txt
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ linux-hpe4/Documentation/x86/x86_64/numa_hotplug_emulator.txt	2010-12=
-07 08:53:19.677622002 +0800
> @@ -0,0 +1,102 @@
> +NUMA Hotplug Emulator for x86_64
> +---------------------------------------------------
> +
> +NUMA hotplug emulator is able to emulate NUMA Node Hotplug
> +thru a pure software way. It intends to help people easily debug
> +and test node/CPU/memory hotplug related stuff on a
> +none-NUMA-hotplug-support machine, even a UMA machine and virtual
> +environment.
> +
> +1) Node hotplug emulation:
> +
> +Adds a numa=3Dpossible=3D<N> command line option to set an additional N =
nodes
> +as being possible for memory hotplug.  This set of possible nodes
> +control nr_node_ids and the sizes of several dynamically allocated node
> +arrays.
> +
> +This allows memory hotplug to create new nodes for newly added memory
> +rather than binding it to existing nodes.
> +
> +For emulation on x86, it would be possible to set aside memory for hotpl=
ugged
> +nodes (say, anything above 2G) and to add an additional four nodes as be=
ing
> +possible on boot with
> +
> +	mem=3D2G numa=3Dpossible=3D4
> +
> +and then creating a new 128M node at runtime:
> +
> +	# echo 128M@0x80000000 > /sys/kernel/debug/node/add_node
> +	On node 1 totalpages: 0
> +	init_memory_mapping: 0000000080000000-0000000088000000
> +	 0080000000 - 0088000000 page 2M
> +
> +Once the new node has been added, its memory can be onlined.  If this
> +memory represents memory section 16, for example:
> +
> +	# echo online > /sys/devices/system/memory/memory16/state
> +	Built 2 zonelists in Node order, mobility grouping on.  Total pages: 51=
4846
> +	Policy zone: Normal
> + [ The memory section(s) mapped to a particular node are visible via
> +   /sys/devices/system/node/node1, in this example. ]
> +
> +2) CPU hotplug emulation:
> +
> +The emulator reserves CPUs thru grub parameter, the reserved CPUs can be
> +hot-add/hot-remove in software method, it emulates the process of physic=
al
> +cpu hotplug.
> +
> +When hotplugging a CPU with emulator, we are using a logical CPU to emul=
ate the
> +CPU socket hotplug process. For the CPU supported SMT, some logical CPUs=
 are in
> +the same socket, but it may located in different NUMA node after we have
> +emulator. We put the logical CPU into a fake CPU socket, and assign it a
> +unique phys_proc_id. For the fake socket, we put one logical CPU in only.
> +
> + - to hide CPUs
> +	- Using boot option "maxcpus=3DN" hide CPUs
> +	  N is the number of CPUs to initialize; the reset will be hidden.
> +	- Using boot option "cpu_hpe=3Don" to enable CPU hotplug emulation
> +      when cpu_hpe is enabled, the rest CPUs will not be initialized
> +
> + - to hot-add CPU to node
> +	# echo nid > cpu/probe
> +
> + - to hot-remove CPU
> +	# echo nid > cpu/release
> +
> +3) Memory hotplug emulation:
> +
> +The emulator reserves memory before OS boots, the reserved memory region=
 is
> +removed from e820 table. Each online node has an add_memory interface, a=
nd
> +memory can be hot-added via the per-ndoe add_memory debugfs interface.
> +
> +The difficulty of Memory Release is well-known, we have no plan for it u=
ntil
> +now.
> +
> + - reserve memory thru a kernel boot paramter
> + 	mem=3D1024m
> +
> + - add a memory section to node 3
> +    # echo 0x40000000 > mem_hotplug/node3/add_memory
> +	OR
> +    # echo 1024m > mem_hotplug/node3/add_memory
> +
> +4) Script for hotplug testing
> +
> +These scripts provides convenience when we hot-add memory/cpu in batch.
> +
> +- Online all memory sections:
> +for m in /sys/devices/system/memory/memory*;
> +do
> +	echo online > $m/state;
> +done
> +
> +- CPU Online:
> +for c in /sys/devices/system/cpu/cpu*;
> +do
> +	echo 1 > $c/online;
> +done
> +
> +- David Rientjes <rientjes@google.com>
> +- Haicheng Li <haicheng.li@intel.com>
> +- Shaohui Zheng <shaohui.zheng@intel.com>
> +  Nov 2010
>=20
> --=20
> Thanks & Regards,
> Shaohui
>=20
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>=20

--C7zPtVaVf+AK4Oqc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJM/nvUAAoJEH65iIruGRnN4jQH/3wn/OE8ZwAXORWGOZhbNzzk
3Ggrw2JfbvRiP9mYOusy6+jFnNA2P8hJKfhNq/kOjYQSHzYdik+Lq489ftlc1yc3
Cph/d0fFne9zKJlKZAl/ZcZT97BSkEUdc0z3G9cy3cJHq93X7biwR+RlMs07U9GI
/b/lz48ujG/ELvhYbXpW3oP0Fr30C6tjJ2WSvhRTZeRdakM3fPDSvHO88azkJZgo
NKQQiEFYyS9IYVTJ4FinchpIs+A0V0t32pqsNYa8MYz+YJpLf2C1xa7+Cn2ynI5G
HEnOSa5TEM2INWHAtRTN0Ww0zMk9HB216IQPfGARwFJi3Qi5/SVvZPIrNChOf4w=
=Tsp+
-----END PGP SIGNATURE-----

--C7zPtVaVf+AK4Oqc--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
