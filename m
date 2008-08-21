Date: Thu, 21 Aug 2008 21:02:48 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 2/2] quicklist shouldn't be proportional to # of CPUs
In-Reply-To: <20080821192130.22B5.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080821183648.22AF.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080821192130.22B5.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080821205307.22B8.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux-foundation.org, tokunaga.keiich@jp.fujitsu.com, travis <travis@sgi.com>
List-ID: <linux-mm.kvack.org>

> 
> Sorry, following patch is crap.
> please forget it.
> 
> I'll respin it soon.

Ah, it's a ok.
it is not crap.

node_to_cpumask_ptr() of generic arch makes local cpumask_t variable.

#define node_to_cpumask_ptr(v, node)                                    \
                cpumask_t _##v = node_to_cpumask(node);                 \
                const cpumask_t *v = &_##v

but gcc optimazer can erase it.
So, it doesn't consume any stack.
checkstack.pl doesn't outpu quicklist related function.


% objdump -d vmlinux | ./scripts/checkstack.pl
0xa000000100647a86 sn2_global_tlb_purge [vmlinux]:      2176
0xa000000100264e86 read_kcore [vmlinux]:                1360
0xa0000001001042a6 crash_save_cpu [vmlinux]:            1152
0xa0000001007869e6 e1000_check_options [vmlinux]:       1152
0xa00000010021b9c6 __mpage_writepage [vmlinux]:         1136
0xa00000010034e9c6 fat_alloc_clusters [vmlinux]:        1136
0xa0000001009c29c6 efi_uart_console_only [vmlinux]:     1136
0xa00000010034afa6 fat_add_entries [vmlinux]:           1088
0xa00000010034d186 fat_free_clusters [vmlinux]:         1088
0xa00000010051f396 tg3_get_estats [vmlinux]:            1072
0xa000000100348f26 fat_alloc_new_dir [vmlinux]:         1040
0xa00000010079df26 cpu_init [vmlinux]:                  1040
0xa00000010020fa46 block_read_full_page [vmlinux]:      1024
0xa00000010021c906 do_mpage_readpage [vmlinux]:         1024
0xa000000100016106 kernel_thread [vmlinux]:             976
0xa000000100031486 convert_to_non_syscall [vmlinux]:    928
0xa0000001001d9486 do_sys_poll [vmlinux]:               848
0xa0000001007a6406 sn_cpu_init [vmlinux]:               768
0xa00000010004bc66 find_save_locs [vmlinux]:            752
0xa0000001009faa26 sn_setup [vmlinux]:                  656
0xa000000100034326 arch_ptrace [vmlinux]:               624
0xa000000100197be6 shmem_getpage [vmlinux]:             624
0xa000000100119046 cpuset_write_resmask [vmlinux]:      608
0xa0000001001da4c6 do_select [vmlinux]:                 592
0xa00000010064dfd0 sn_topology_show [vmlinux]:          592
0xa00000010005b7e6 vm_info [vmlinux]:                   544
0xa0000001007a0026 cache_add_dev [vmlinux]:             544
0xa00000010000beb0 sys_clone2 [vmlinux]:                528
0xa00000010000bf30 sys_clone [vmlinux]:                 528
0xa00000010000bfb0 ia64_native_switch_to [vmlinux]:     528
0xa00000010000cdd0 ia64_prepare_handle_unaligned [vmlinux]:528
0xa00000010000ce40 unw_init_running [vmlinux]:          528
0xa000000100072810 ia32_clone [vmlinux]:                528
0xa0000001000729f0 sys32_fork [vmlinux]:                528
0xa0000001003089c6 log_do_checkpoint [vmlinux]:         528
0xa00000010031de06 jbd2_log_do_checkpoint [vmlinux]:    528
0xa0000001007aefa6 ia64_fault [vmlinux]:                528
0xa000000100030f66 do_regset_call [vmlinux]:            512
0xa000000100036de6 do_fpregs_set [vmlinux]:             512
0xa000000100073446 do_regset_call [vmlinux]:            512
0xa000000100194246 sys_migrate_pages [vmlinux]:         512
0xa0000001003676a6 sys_semctl [vmlinux]:                512
0xa000000100038286 do_fpregs_get [vmlinux]:             480
0xa000000100200f46 sys_vmsplice [vmlinux]:              480
0xa000000100640490 print_hook [vmlinux]:                480
0xa00000010064ab26 sn_hwperf_get_nearest_node_objdata [vmlinux]:480
0xa000000100797966 sym2_probe [vmlinux]:                480
0xa00000010000ce50 unw_init_running [vmlinux]:          464
0xa000000100015e26 get_wchan [vmlinux]:                 464
0xa0000001000177e6 show_stack [vmlinux]:                464
0xa000000100035fa6 ptrace_attach_sync_user_rbs [vmlinux]:464
0xa000000100042786 ia64_handle_unaligned [vmlinux]:     464
0xa00000010009ace6 sched_show_task [vmlinux]:           464
0xa0000001003664a6 sys_semtimedop [vmlinux]:            464
0xa00000010064bec6 sn_hwperf_init [vmlinux]:            464
0xa0000001001043c6 crash_kexec [vmlinux]:               448
0xa000000100217646 __blkdev_get [vmlinux]:              448
0xa000000100672aa6 skb_splice_bits [vmlinux]:           448
0xa0000001007a35a6 fork_idle [vmlinux]:                 448
0xa0000001009c95a6 ia64_mca_init [vmlinux]:             448
0xa0000001009ee766 scdrv_init [vmlinux]:                448
0xa000000100128026 relay_file_splice_read [vmlinux]:    432
0xa000000100200346 generic_file_splice_read [vmlinux]:  432
0xa0000001004bf226 node_read_meminfo [vmlinux]:         432
0xa0000001006d54c6 do_ip_setsockopt [vmlinux]:          432
0xa00000010044e1c6 extract_buf [vmlinux]:               416
0xa00000010005ae06 register_info [vmlinux]:             400
0xa0000001005fb3f6 raid6_int32_gen_syndrome [vmlinux]:  400
0xa000000100066ac6 mca_try_to_recover [vmlinux]:        384
0xa000000100262466 meminfo_read_proc [vmlinux]:         384
0xa0000001006605a6 sock_recvmsg [vmlinux]:              368
0xa000000100661106 sock_sendmsg [vmlinux]:              368
0xa000000100664226 sys_sendmsg [vmlinux]:               368
0xa0000001009b8c06 md_run_setup [vmlinux]:              368
0xa000000100160086 unmap_vmas [vmlinux]:                352
0xa00000010025d866 do_task_stat [vmlinux]:              352
0xa00000010077d3a6 ia64_tlb_init [vmlinux]:             352
0xa000000100054196 ia64_mca_printk [vmlinux]:           336
0xa000000100058c46 tr_info [vmlinux]:                   336
0xa000000100066356 mca_recovered [vmlinux]:             336
0xa000000100066436 fatal_mca [vmlinux]:                 336
0xa0000001006d4026 do_ip_getsockopt [vmlinux]:          336
0xa000000100015a06 cpu_halt [vmlinux]:                  320
0xa000000100119ca6 cpuset_attach [vmlinux]:             320
0xa00000010064cab0 sn_hwperf_ioctl [vmlinux]:           320
0xa000000100660786 sys_recvmsg [vmlinux]:               320
0xa0000001006c4666 cleanup_once [vmlinux]:              320
0xa0000001006c5066 inet_getpeer [vmlinux]:              320
0xa0000001000a8e56 warn_slowpath [vmlinux]:             304
0xa000000100117906 update_flag [vmlinux]:               304
0xa0000001001daca6 core_sys_select [vmlinux]:           304
0xa000000100234bc6 compat_core_sys_select [vmlinux]:    304
0xa00000010038e9c6 blk_recount_segments [vmlinux]:      304
0xa000000100487486 scdrv_write [vmlinux]:               304
0xa000000100487e66 scdrv_read [vmlinux]:                304
0xa0000001004890c6 scdrv_event [vmlinux]:               304
0xa0000001005561c6 scsi_reset_provider [vmlinux]:       304
0xa00000010078d266 tg3_get_invariants [vmlinux]:        304


Conclusion:
This patch can queue to upstream IMHO.



> > 
> > ---
> >  mm/quicklist.c |    9 ++++++++-
> >  1 file changed, 8 insertions(+), 1 deletion(-)
> > 
> > Index: b/mm/quicklist.c
> > ===================================================================
> > --- a/mm/quicklist.c
> > +++ b/mm/quicklist.c
> > @@ -26,7 +26,10 @@ DEFINE_PER_CPU(struct quicklist, quickli
> >  static unsigned long max_pages(unsigned long min_pages)
> >  {
> >  	unsigned long node_free_pages, max;
> > -	struct zone *zones = NODE_DATA(numa_node_id())->node_zones;
> > +	int node = numa_node_id();
> > +	struct zone *zones = NODE_DATA(node)->node_zones;
> > +	int num_cpus_on_node;
> > +	node_to_cpumask_ptr(cpumask_on_node, node);
> >  
> >  	node_free_pages =
> >  #ifdef CONFIG_ZONE_DMA
> > @@ -38,6 +41,10 @@ static unsigned long max_pages(unsigned 
> >  		zone_page_state(&zones[ZONE_NORMAL], NR_FREE_PAGES);
> >  
> >  	max = node_free_pages / FRACTION_OF_NODE_MEM;
> > +
> > +	num_cpus_on_node = cpus_weight_nr(*cpumask_on_node);
> > +	max /= num_cpus_on_node;
> > +
> >  	return max(max, min_pages);
> >  }
> 
> 
> 
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
