Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D746E6B0095
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 11:35:07 -0500 (EST)
Received: by pzk27 with SMTP id 27so608762pzk.9
        for <linux-mm@kvack.org>; Thu, 16 Dec 2010 08:34:23 -0800 (PST)
Date: Thu, 16 Dec 2010 09:25:41 -0700
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [5/7, v9] NUMA Hotplug Emulator: Support cpu probe/release in
 x86_64
Message-ID: <20101216162541.GA14157@mgebm.net>
References: <20101210073119.156388875@intel.com>
 <20101210073242.670777298@intel.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="OXfL5xGRrasGEqWY"
Content-Disposition: inline
In-Reply-To: <20101210073242.670777298@intel.com>
Sender: owner-linux-mm@kvack.org
To: shaohui.zheng@intel.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, rientjes@google.com, dave@linux.vnet.ibm.com, gregkh@suse.de, Ingo Molnar <mingo@elte.hu>, Len Brown <len.brown@intel.com>, Yinghai Lu <Yinghai.Lu@Sun.COM>, Tejun Heo <tj@kernel.org>, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>


--OXfL5xGRrasGEqWY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Shaohui,

What kernel is this series based on?  I cannot get it to build when applied
to mainline.  I seem to be missing a definition for set_apicid_to_node.

Eric

On Fri, 10 Dec 2010, shaohui.zheng@intel.com wrote:

> From: Shaohui Zheng <shaohui.zheng@intel.com>
>=20
> CPU physical hot-add/hot-remove are supported on some hardwares, and it=
=20
> was already supported in current linux kernel. NUMA Hotplug Emulator prov=
ides
> a mechanism to emulate the process with software method. It can be used f=
or
> testing or debuging purpose.
>=20
> CPU physical hotplug is different with logical CPU online/offline. Logical
> online/offline is controled by interface /sys/device/cpu/cpuX/online. CPU
> hotplug emulator uses probe/release interface. It becomes possible to do =
cpu
> hotplug automation and stress
>=20
> Add cpu interface probe/release under sysfs for x86_64. User can use this
> interface to emulate the cpu hot-add and hot-remove process.
>=20
> Directive:
> *) Reserve CPU thru grub parameter like:
> 	maxcpus=3D4
>=20
> the rest CPUs will not be initiliazed.=20
>=20
> *) Probe CPU
> we can use the probe interface to hot-add new CPUs:
> 	echo nid > /sys/devices/system/cpu/probe
>=20
> *) Release a CPU
> 	echo cpu > /sys/devices/system/cpu/release
>=20
> A reserved CPU will be hot-added to the specified node.
> 1) nid =3D=3D 0, the CPU will be added to the real node which the CPU
> should be in
> 2) nid !=3D 0, add the CPU to node nid even through it is a fake node.
>=20
> CC: Ingo Molnar <mingo@elte.hu>
> CC: Len Brown <len.brown@intel.com>
> CC: Yinghai Lu <Yinghai.Lu@Sun.COM>
> CC: Tejun Heo <tj@kernel.org>
> Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
> Signed-off-by: Haicheng Li <haicheng.li@intel.com>
> ---
> This patch is based on Tejun's unification of the 32 and 64 bit NUMA boot=
 paths,
>  specifically the patch at http://marc.info/?l=3Dlinux-kernel&m=3D1290871=
51912379.
> Index: linux-hpe4/arch/x86/kernel/acpi/boot.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-hpe4.orig/arch/x86/kernel/acpi/boot.c	2010-12-10 13:42:34.55333=
1000 +0800
> +++ linux-hpe4/arch/x86/kernel/acpi/boot.c	2010-12-10 14:48:32.113331001 =
+0800
> @@ -668,8 +668,39 @@
>  }
>  EXPORT_SYMBOL(acpi_map_lsapic);
> =20
> +#ifdef CONFIG_ARCH_CPU_PROBE_RELEASE
> +static void acpi_map_cpu2node_emu(int cpu, int physid, int nid)
> +{
> +#ifdef CONFIG_ACPI_NUMA
> +	set_apicid_to_node(physid, nid);
> +	numa_set_node(cpu, nid);
> +#endif
> +}
> +
> +static u16 cpu_to_apicid_saved[CONFIG_NR_CPUS];
> +int __ref acpi_map_lsapic_emu(int pcpu, int nid)
> +{
> +	/* backup cpu apicid to array cpu_to_apicid_saved */
> +	if (cpu_to_apicid_saved[pcpu] =3D=3D 0 &&
> +		per_cpu(x86_cpu_to_apicid, pcpu) !=3D BAD_APICID)
> +		cpu_to_apicid_saved[pcpu] =3D per_cpu(x86_cpu_to_apicid, pcpu);
> +
> +	per_cpu(x86_cpu_to_apicid, pcpu) =3D cpu_to_apicid_saved[pcpu];
> +	acpi_map_cpu2node_emu(pcpu, per_cpu(x86_cpu_to_apicid, pcpu), nid);
> +
> +	return pcpu;
> +}
> +EXPORT_SYMBOL(acpi_map_lsapic_emu);
> +#endif
> +
>  int acpi_unmap_lsapic(int cpu)
>  {
> +#ifdef CONFIG_ARCH_CPU_PROBE_RELEASE
> +	/* backup cpu apicid to array cpu_to_apicid_saved */
> +	if (cpu_to_apicid_saved[cpu] =3D=3D 0 &&
> +		per_cpu(x86_cpu_to_apicid, cpu) !=3D BAD_APICID)
> +		cpu_to_apicid_saved[cpu] =3D per_cpu(x86_cpu_to_apicid, cpu);
> +#endif
>  	per_cpu(x86_cpu_to_apicid, cpu) =3D -1;
>  	set_cpu_present(cpu, false);
>  	num_processors--;
> Index: linux-hpe4/arch/x86/kernel/smpboot.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-hpe4.orig/arch/x86/kernel/smpboot.c	2010-12-10 13:42:34.5633310=
00 +0800
> +++ linux-hpe4/arch/x86/kernel/smpboot.c	2010-12-10 14:48:32.113331001 +0=
800
> @@ -103,8 +103,6 @@
>          mutex_unlock(&x86_cpu_hotplug_driver_mutex);
>  }
> =20
> -ssize_t arch_cpu_probe(const char *buf, size_t count) { return -1; }
> -ssize_t arch_cpu_release(const char *buf, size_t count) { return -1; }
>  #else
>  static struct task_struct *idle_thread_array[NR_CPUS] __cpuinitdata ;
>  #define get_idle_for_cpu(x)      (idle_thread_array[(x)])
> Index: linux-hpe4/arch/x86/kernel/topology.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-hpe4.orig/arch/x86/kernel/topology.c	2010-12-10 14:39:43.333331=
000 +0800
> +++ linux-hpe4/arch/x86/kernel/topology.c	2010-12-10 14:49:56.043331000 +=
0800
> @@ -30,6 +30,9 @@
>  #include <linux/init.h>
>  #include <linux/smp.h>
>  #include <asm/cpu.h>
> +#include <linux/cpu.h>
> +#include <linux/topology.h>
> +#include <linux/acpi.h>
> =20
>  static DEFINE_PER_CPU(struct x86_cpu, cpu_devices);
> =20
> @@ -66,6 +69,78 @@
>  	unregister_cpu(&per_cpu(cpu_devices, num).cpu);
>  }
>  EXPORT_SYMBOL(arch_unregister_cpu);
> +
> +ssize_t arch_cpu_probe(const char *buf, size_t count)
> +{
> +	int nid =3D 0;
> +	int num =3D 0, selected =3D 0;
> +
> +	/* check parameters */
> +	if (!buf || count < 2)
> +		return -EPERM;
> +
> +	nid =3D simple_strtoul(buf, NULL, 0);
> +	printk(KERN_DEBUG "Add a cpu to node : %d\n", nid);
> +
> +	if (nid < 0 || nid > nr_node_ids - 1) {
> +		printk(KERN_ERR "Invalid NUMA node id: %d (0 <=3D nid < %d).\n",
> +			nid, nr_node_ids);
> +		return -EPERM;
> +	}
> +
> +	if (!node_online(nid)) {
> +		printk(KERN_ERR "NUMA node %d is not online, give up.\n", nid);
> +		return -EPERM;
> +	}
> +
> +	/* find first uninitialized cpu */
> +	for_each_present_cpu(num) {
> +		if (per_cpu(cpu_sys_devices, num) =3D=3D NULL) {
> +			selected =3D num;
> +			break;
> +		}
> +	}
> +
> +	if (selected >=3D num_possible_cpus()) {
> +		printk(KERN_ERR "No free cpu, give up cpu probing.\n");
> +		return -EPERM;
> +	}
> +
> +	/* register cpu */
> +	arch_register_cpu_node(selected, nid);
> +	acpi_map_lsapic_emu(selected, nid);
> +
> +	return count;
> +}
> +EXPORT_SYMBOL(arch_cpu_probe);
> +
> +ssize_t arch_cpu_release(const char *buf, size_t count)
> +{
> +	int cpu =3D 0;
> +
> +	cpu =3D  simple_strtoul(buf, NULL, 0);
> +	/* cpu 0 is not hotplugable */
> +	if (cpu =3D=3D 0) {
> +		printk(KERN_ERR "can not release cpu 0.\n");
> +		return -EPERM;
> +	}
> +
> +	if (cpu_online(cpu)) {
> +		printk(KERN_DEBUG "offline cpu %d.\n", cpu);
> +		if (!cpu_down(cpu)) {
> +			printk(KERN_ERR "fail to offline cpu %d, give up.\n", cpu);
> +			return -EPERM;
> +		}
> +
> +	}
> +
> +	arch_unregister_cpu(cpu);
> +	acpi_unmap_lsapic(cpu);
> +
> +	return count;
> +}
> +EXPORT_SYMBOL(arch_cpu_release);
> +
>  #else /* CONFIG_HOTPLUG_CPU */
> =20
>  static int __init arch_register_cpu(int num)
> @@ -83,8 +158,14 @@
>  		register_one_node(i);
>  #endif
> =20
> -	for_each_present_cpu(i)
> -		arch_register_cpu(i);
> +	/*
> +	 * when cpu hotplug emulation enabled, register the online cpu only,
> +	 * the rests are reserved for cpu probe.
> +	 */
> +	for_each_present_cpu(i) {
> +		if ((cpu_hpe_on && cpu_online(i)) || !cpu_hpe_on)
> +			arch_register_cpu(i);
> +	}
> =20
>  	return 0;
>  }
> Index: linux-hpe4/arch/x86/mm/numa_64.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-hpe4.orig/arch/x86/mm/numa_64.c	2010-12-10 14:39:37.153331000 +=
0800
> +++ linux-hpe4/arch/x86/mm/numa_64.c	2010-12-10 14:48:32.123331001 +0800
> @@ -13,6 +13,7 @@
>  #include <linux/module.h>
>  #include <linux/nodemask.h>
>  #include <linux/sched.h>
> +#include <linux/cpu.h>
> =20
>  #include <asm/e820.h>
>  #include <asm/proto.h>
> @@ -667,3 +668,17 @@
>  		return __apicid_to_node[apicid];
>  	return NUMA_NO_NODE;
>  }
> +
> +#ifdef CONFIG_ARCH_CPU_PROBE_RELEASE
> +static __init int cpu_hpe_setup(char *opt)
> +{
> +	if (!opt)
> +		return -EINVAL;
> +
> +	if (!strncmp(opt, "on", 2) || !strncmp(opt, "1", 1))
> +		cpu_hpe_on =3D 1;
> +
> +	return 0;
> +}
> +early_param("cpu_hpe", cpu_hpe_setup);
> +#endif  /* CONFIG_ARCH_CPU_PROBE_RELEASE */
> Index: linux-hpe4/drivers/acpi/processor_driver.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-hpe4.orig/drivers/acpi/processor_driver.c	2010-12-10 13:42:34.5=
93331000 +0800
> +++ linux-hpe4/drivers/acpi/processor_driver.c	2010-12-10 14:48:32.143331=
001 +0800
> @@ -542,6 +542,14 @@
>  		goto err_free_cpumask;
> =20
>  	sysdev =3D get_cpu_sysdev(pr->id);
> +	/*
> +	 * Reserve cpu for hotplug emulation, the reserved cpu can be hot-added
> +	 * throu the cpu probe interface. Return directly.
> +	 */
> +	if (sysdev =3D=3D NULL) {
> +		goto out;
> +	}
> +
>  	if (sysfs_create_link(&device->dev.kobj, &sysdev->kobj, "sysdev")) {
>  		result =3D -EFAULT;
>  		goto err_remove_fs;
> @@ -582,6 +590,7 @@
>  		goto err_remove_sysfs;
>  	}
> =20
> +out:
>  	return 0;
> =20
>  err_remove_sysfs:
> Index: linux-hpe4/drivers/base/cpu.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-hpe4.orig/drivers/base/cpu.c	2010-12-10 14:39:43.333331000 +0800
> +++ linux-hpe4/drivers/base/cpu.c	2010-12-10 14:48:32.143331001 +0800
> @@ -22,9 +22,15 @@
>  };
>  EXPORT_SYMBOL(cpu_sysdev_class);
> =20
> -static DEFINE_PER_CPU(struct sys_device *, cpu_sys_devices);
> +DEFINE_PER_CPU(struct sys_device *, cpu_sys_devices);
> =20
>  #ifdef CONFIG_HOTPLUG_CPU
> +/*
> + * cpu_hpe_on is a switch to enable/disable cpu hotplug emulation. it is
> + * disabled in default, we can enable it throu grub parameter cpu_hpe=3D=
on
> + */
> +int cpu_hpe_on;
> +
>  static ssize_t show_online(struct sys_device *dev, struct sysdev_attribu=
te *attr,
>  			   char *buf)
>  {
> Index: linux-hpe4/include/linux/acpi.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-hpe4.orig/include/linux/acpi.h	2010-12-10 13:42:34.613331000 +0=
800
> +++ linux-hpe4/include/linux/acpi.h	2010-12-10 14:48:32.153331001 +0800
> @@ -102,6 +102,7 @@
>  #ifdef CONFIG_ACPI_HOTPLUG_CPU
>  /* Arch dependent functions for cpu hotplug support */
>  int acpi_map_lsapic(acpi_handle handle, int *pcpu);
> +int acpi_map_lsapic_emu(int pcpu, int nid);
>  int acpi_unmap_lsapic(int cpu);
>  #endif /* CONFIG_ACPI_HOTPLUG_CPU */
> =20
> Index: linux-hpe4/include/linux/cpu.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-hpe4.orig/include/linux/cpu.h	2010-12-10 14:39:43.333331000 +08=
00
> +++ linux-hpe4/include/linux/cpu.h	2010-12-10 14:48:32.153331001 +0800
> @@ -25,6 +25,8 @@
>  	struct sys_device sysdev;
>  };
> =20
> +DECLARE_PER_CPU(struct sys_device *, cpu_sys_devices);
> +
>  extern int register_cpu_node(struct cpu *cpu, int num, int nid);
> =20
>  static inline int register_cpu(struct cpu *cpu, int num)
> @@ -144,6 +146,7 @@
>  #define register_hotcpu_notifier(nb)	register_cpu_notifier(nb)
>  #define unregister_hotcpu_notifier(nb)	unregister_cpu_notifier(nb)
>  int cpu_down(unsigned int cpu);
> +extern int cpu_hpe_on;
> =20
>  #ifdef CONFIG_ARCH_CPU_PROBE_RELEASE
>  extern void cpu_hotplug_driver_lock(void);
> @@ -166,6 +169,7 @@
>  /* These aren't inline functions due to a GCC bug. */
>  #define register_hotcpu_notifier(nb)	({ (void)(nb); 0; })
>  #define unregister_hotcpu_notifier(nb)	({ (void)(nb); })
> +static int cpu_hpe_on;
>  #endif		/* CONFIG_HOTPLUG_CPU */
> =20
>  #ifdef CONFIG_PM_SLEEP_SMP
> Index: linux-hpe4/Documentation/x86/x86_64/boot-options.txt
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-hpe4.orig/Documentation/x86/x86_64/boot-options.txt	2010-12-10 =
14:39:37.153331000 +0800
> +++ linux-hpe4/Documentation/x86/x86_64/boot-options.txt	2010-12-10 14:48=
:32.153331001 +0800
> @@ -320,3 +320,8 @@
>  		Do not use GB pages for kernel direct mappings.
>  	gbpages
>  		Use GB pages for kernel direct mappings.
> +	cpu_hpe=3Don/off
> +		Enable/disable CPU hotplug emulation with software method. When cpu_hp=
e=3Don,
> +		sysfs provides probe/release interface to hot add/remove CPUs dynamica=
lly.
> +		We can use maxcpus=3D<N> to reserve CPUs.
> +		This option is disabled by default.
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

--OXfL5xGRrasGEqWY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNCj2FAAoJEH65iIruGRnN38kH/iP8FEOaQlQ2Bjt1xMnVEJA8
IygzC3uH/I1YQWGUHgbJymkuSZeoBjc5tZcC2if0h0F6TEKoLzo8xZryk08m9c/N
7uMvR0tlZVE0JamFZrGm1ppm+Q/49arSY5el3l6bbw7J6RRU5j2SBApwHXKmIAWN
cqtsJ1gfwYcidj6Jtzitx3mDZx3yEbgryOogk/ymhY2B2mkNaeCJ7zSHwj63gGAN
mdUhUotEj1kOyk2DPX/+6awFGbgmHcylytZcTicpyoHmNgzykQDnsF7Rpm74NAWz
9ijQA7LkHIRxJIve1yMT0fwbiiKLyaxI0Uw9BSPA4vohpuk26tdwZy1jeaoHOyw=
=7CBF
-----END PGP SIGNATURE-----

--OXfL5xGRrasGEqWY--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
