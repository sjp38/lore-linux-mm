Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id AB4A56B01F0
	for <linux-mm@kvack.org>; Sat, 15 May 2010 09:17:05 -0400 (EDT)
Received: by gwb20 with SMTP id 20so1868434gwb.14
        for <linux-mm@kvack.org>; Sat, 15 May 2010 06:17:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100513114544.GC2169@shaohui>
References: <20100513114544.GC2169@shaohui>
Date: Sat, 15 May 2010 18:47:00 +0530
Message-ID: <AANLkTikZiRw2w9hveCxA2XQp8SYs-4rYpH4BdZOns2CS@mail.gmail.com>
Subject: Re: [RFC,2/7] NUMA Hotplug emulator
From: Jaswinder Singh Rajput <jaswinderlinux@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Yinghai Lu <yinghai@kernel.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-kernel@vger.kernel.org, ak@linux.intel.co, fengguang.wu@intel.com, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

Hello,

On Thu, May 13, 2010 at 5:15 PM, Shaohui Zheng <shaohui.zheng@intel.com> wr=
ote:
> x86: infrastructure of NUMA hotplug emulation
>
> NUMA hotplug emulator introduces a new node state N_HIDDEN to
> identify the fake offlined node. It firstly hides RAM via E820
> table and then emulates fake offlined nodes with the hidden RAM.
>
> After system bootup, user is able to hotplug-add these offlined
> nodes, which is just similar to a real hardware hotplug behavior.
>
> Using boot option "numa=3Dhide=3DN*size" to fake offlined nodes:
> =A0 =A0 =A0 =A0- N is the number of hidden nodes
> =A0 =A0 =A0 =A0- size is the memory size (in MB) per hidden node.
>
> OPEN: Kernel might use part of hidden memory region as RAM buffer,
> =A0 =A0 =A0now emulator directly hide 128M extra space to workaround
> =A0 =A0 =A0this issue. =A0Any better way to avoid this conflict?
>
> Signed-off-by: Haicheng Li <haicheng.li@linux.intel.com>
> Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
> ---
> diff --git a/arch/x86/mm/numa_64.c b/arch/x86/mm/numa_64.c
> index 8948f47..3e0d94d 100644
> --- a/arch/x86/mm/numa_64.c
> +++ b/arch/x86/mm/numa_64.c
> @@ -307,6 +307,87 @@ void __init numa_init_array(void)
> =A0 =A0 =A0 =A0}
> =A0}
>
> +#ifdef CONFIG_NODE_HOTPLUG_EMU
> +static char *hp_cmdline __initdata;
> +static struct bootnode *hidden_nodes;
> +static u64 hp_start, hp_end;
> +static long hidden_num, hp_size;
> +
> +int hotadd_hidden_nodes(int nid)
> +{
> + =A0 =A0 =A0 int ret;
> +
> + =A0 =A0 =A0 if (!node_hidden(nid))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> +
> + =A0 =A0 =A0 ret =3D add_memory(nid, hidden_nodes[nid].start,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hidden_nodes[nid].end - =
hidden_nodes[nid].start);
> + =A0 =A0 =A0 if (!ret) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 node_clear_hidden(nid);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EEXIST;
> + =A0 =A0 =A0 }
> +}
> +
> +static void __init numa_hide_nodes(void)
> +{
> + =A0 =A0 =A0 char *c;
> + =A0 =A0 =A0 int ret;
> +
> + =A0 =A0 =A0 c =3D strchr(hp_cmdline, '*');
> + =A0 =A0 =A0 if (!c)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 *c =3D '\0';
> + =A0 =A0 =A0 ret =3D strict_strtol(hp_cmdline, 0, &hidden_num);
> + =A0 =A0 =A0 if (ret =3D=3D -EINVAL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 ret =3D strict_strtol(c + 1, 0, &hp_size);
> + =A0 =A0 =A0 if (ret =3D=3D -EINVAL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 hp_size <<=3D 20;
> +
> + =A0 =A0 =A0 hp_start =3D e820_hide_mem(hidden_num * hp_size);
> + =A0 =A0 =A0 if (hp_start <=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "Hide too much memory, disa=
ble node hotplug emualtion.");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 hidden_num =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 hp_end =3D hp_start + hidden_num * hp_size;
> +
> + =A0 =A0 =A0 /* leave 128M space for possible RAM buffer usage later
> + =A0 =A0 =A0 =A0* any other better way to avoid this conflict?
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 e820_hide_mem(128*1024*1024);
> +}
> +
> +static void __init numa_hotplug_emulation(void)
> +{
> + =A0 =A0 =A0 int i, num_nodes =3D 0;
> +
> + =A0 =A0 =A0 for_each_online_node(i)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (i > num_nodes)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 num_nodes =3D i;
> +
> + =A0 =A0 =A0 i =3D num_nodes + hidden_num;
> + =A0 =A0 =A0 if (!hidden_nodes) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 hidden_nodes =3D alloc_bootmem(sizeof(struc=
t bootnode) * i);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memset(hidden_nodes, 0, sizeof(struct bootn=
ode) * i);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (hidden_num)

if (hidden_num) is not required, as next line's for statement is also
doing the same thing.

Thanks,
--
Jaswinder Singh.

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D 0; i < hidden_num; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int nid =3D num_nodes + i +=
 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 node_set(nid, node_possible=
_map);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hidden_nodes[nid].start =3D=
 hp_start + hp_size * i;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hidden_nodes[nid].end =3D h=
p_start + hp_size * (i+1);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 node_set_hidden(nid);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +}
> +#endif /* CONFIG_NODE_HOTPLUG_EMU */
> +
> =A0#ifdef CONFIG_NUMA_EMU
> =A0/* Numa emulation */
> =A0static struct bootnode nodes[MAX_NUMNODES] __initdata;
> @@ -661,7 +742,7 @@ void __init initmem_init(unsigned long start_pfn, uns=
igned long last_pfn,
>
> =A0#ifdef CONFIG_NUMA_EMU
> =A0 =A0 =A0 =A0if (cmdline && !numa_emulation(start_pfn, last_pfn, acpi, =
k8))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto done;
> =A0 =A0 =A0 =A0nodes_clear(node_possible_map);
> =A0 =A0 =A0 =A0nodes_clear(node_online_map);
> =A0#endif
> @@ -669,14 +750,14 @@ void __init initmem_init(unsigned long start_pfn, u=
nsigned long last_pfn,
> =A0#ifdef CONFIG_ACPI_NUMA
> =A0 =A0 =A0 =A0if (!numa_off && acpi && !acpi_scan_nodes(start_pfn << PAG=
E_SHIFT,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0last_pfn << PAGE_SHIFT))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto done;
> =A0 =A0 =A0 =A0nodes_clear(node_possible_map);
> =A0 =A0 =A0 =A0nodes_clear(node_online_map);
> =A0#endif
>
> =A0#ifdef CONFIG_K8_NUMA
> =A0 =A0 =A0 =A0if (!numa_off && k8 && !k8_scan_nodes())
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto done;
> =A0 =A0 =A0 =A0nodes_clear(node_possible_map);
> =A0 =A0 =A0 =A0nodes_clear(node_online_map);
> =A0#endif
> @@ -696,6 +777,12 @@ void __init initmem_init(unsigned long start_pfn, un=
signed long last_pfn,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0numa_set_node(i, 0);
> =A0 =A0 =A0 =A0e820_register_active_regions(0, start_pfn, last_pfn);
> =A0 =A0 =A0 =A0setup_node_bootmem(0, start_pfn << PAGE_SHIFT, last_pfn <<=
 PAGE_SHIFT);
> +done:
> +#ifdef CONFIG_NODE_HOTPLUG_EMU
> + =A0 =A0 =A0 if (hidden_num)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 numa_hotplug_emulation();
> +#endif
> + =A0 =A0 =A0 return;
> =A0}
>
> =A0unsigned long __init numa_free_all_bootmem(void)
> @@ -723,6 +810,12 @@ static __init int numa_setup(char *opt)
> =A0 =A0 =A0 =A0if (!strncmp(opt, "fake=3D", 5))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cmdline =3D opt + 5;
> =A0#endif
> +#ifdef CONFIG_NODE_HOTPLUG_EMU
> + =A0 =A0 =A0 if (!strncmp(opt, "hide=3D", 5)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 hp_cmdline =3D opt + 5;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 numa_hide_nodes();
> + =A0 =A0 =A0 }
> +#endif
> =A0#ifdef CONFIG_ACPI_NUMA
> =A0 =A0 =A0 =A0if (!strncmp(opt, "noacpi", 6))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0acpi_numa =3D -1;
> diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
> index dba35e4..ba0f82d 100644
> --- a/include/linux/nodemask.h
> +++ b/include/linux/nodemask.h
> @@ -371,6 +371,10 @@ static inline void __nodes_fold(nodemask_t *dstp, co=
nst nodemask_t *origp,
> =A0*/
> =A0enum node_states {
> =A0 =A0 =A0 =A0N_POSSIBLE, =A0 =A0 =A0 =A0 =A0 =A0 /* The node could beco=
me online at some point */
> +#ifdef CONFIG_NODE_HOTPLUG_EMU
> + =A0 =A0 =A0 N_HIDDEN, =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* The node is hidden=
 at booting time, could be
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* online=
d in run time */
> +#endif
> =A0 =A0 =A0 =A0N_ONLINE, =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* The node is onlin=
e */
> =A0 =A0 =A0 =A0N_NORMAL_MEMORY, =A0 =A0 =A0 =A0/* The node has regular me=
mory */
> =A0#ifdef CONFIG_HIGHMEM
> @@ -470,6 +474,13 @@ static inline int num_node_state(enum node_states st=
ate)
> =A0#define node_online(node) =A0 =A0 =A0node_state((node), N_ONLINE)
> =A0#define node_possible(node) =A0 =A0node_state((node), N_POSSIBLE)
>
> +#ifdef CONFIG_NODE_HOTPLUG_EMU
> +#define node_set_hidden(node) =A0 =A0 node_set_state((node), N_HIDDEN)
> +#define node_clear_hidden(node) =A0 =A0 =A0 =A0 =A0 node_clear_state((no=
de), N_HIDDEN)
> +#define node_hidden(node) =A0 =A0 =A0node_state((node), N_HIDDEN)
> +extern int hotadd_hidden_nodes(int nid);
> +#endif
> +
> =A0#define for_each_node(node) =A0 =A0 =A0 for_each_node_state(node, N_PO=
SSIBLE)
> =A0#define for_each_online_node(node) for_each_node_state(node, N_ONLINE)
>
> --
> Thanks & Regards,
> Shaohui
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
