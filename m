Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 6D5896B004F
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 10:56:23 -0500 (EST)
Received: by wgbds13 with SMTP id ds13so4861626wgb.26
        for <linux-mm@kvack.org>; Fri, 09 Dec 2011 07:56:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111209115513.GA19994@infradead.org>
References: <CAAnfqPAm559m-Bv8LkHARm7iBW5Kfs7NmjTFidmg-idhcOq4sQ@mail.gmail.com>
	<20111209115513.GA19994@infradead.org>
Date: Fri, 9 Dec 2011 10:56:20 -0500
Message-ID: <CAAnfqPABS_-3rU_KxWvXrQpJvWLr09jEYUDG=gUMuTX8LSan4Q@mail.gmail.com>
Subject: Re: XFS causing stack overflow
From: "Ryan C. England" <ryan.england@corvidtec.com>
Content-Type: multipart/alternative; boundary=0015174bf0707263fd04b3aad341
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: xfs@oss.sgi.com, linux-mm@kvack.org

--0015174bf0707263fd04b3aad341
Content-Type: text/plain; charset=ISO-8859-1

Chris,

Thanks for the reply.  You have been a great help.

Do you know if these changes were implemented any farther back than 3.2?  I
wouldn't feel comfortable running a release candidate kernel in a
production environment.

Thanks again

On Fri, Dec 9, 2011 at 6:55 AM, Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, Dec 08, 2011 at 01:03:51PM -0500, Ryan C. England wrote:
> > I am looking for assistance on XFS which is why I have joined this
> mailing
> > list.  I'm receiving a stack overflow on our file server.  The server is
> > running Scientific Linux 6.1 with the following kernel,
> > 2.6.32-131.21.1.el6.x86_64.
> >
> > This is causing random reboots which is more annoying than anything.  I
> > found a couple of links in the archives but wasn't quite sure how to
> apply
> > this patch.  I can provide whatever information necessary in order for
> > assistance in troubleshooting.
>
> It's really mostly an issue with the VM page reclaim and writeback
> code.  The kernel still has the old balance dirty pages code which calls
> into writeback code from the stack of the write system call, which
> already comes from NFSD with massive amounts of stack used.  Then
> the writeback code calls into XFS to write data out, then you get the
> full XFS btree code, which then ends up in kmalloc and memory reclaim.
>
> You probably have only a third of the stack actually used by XFS, the
> rest is from NFSD/writeback code and page reclaim.  I don't think any
> of this is easily fixable in a 2.6.32 codebase.  Current mainline 3.2-rc
> now has the I/O-less balance dirty pages which will basically split the
> stack footprint in half, but it's an invasive change to the writeback
> code that isn't easily backportable.
>
> > Dec  6 20:27:55 localhost kernel: ------------[ cut here ]------------
> > Dec  6 20:27:55 localhost kernel: WARNING: at arch/x86/kernel/irq_64.c:47
> > handle_irq+0x8f/0xa0() (Not tainted)
> > Dec  6 20:27:55 localhost kernel: Hardware name: X8DTH-i/6/iF/6F
> > Dec  6 20:27:55 localhost kernel: do_IRQ: nfsd near stack overflow
> > (cur:ffff880622208000,sp:ffff880622208160)
> > Dec  6 20:27:55 localhost kernel: Modules linked in: mpt2sas
> > scsi_transport_sas raid_class mptctl mptbase nfsd lockd nfs_acl
> auth_rpcgss
> > autofs4 sunrpc cpufreq_ondemand acpi_cpufreq freq_table ip6t_REJECT
> > nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter
> > ip6_tables ipv6 xfs exportfs dm_mirror dm_region_hash dm_log ses
> enclosure
> > ixgbe mdio microcode igb serio_raw ghes hed i2c_i801 i2c_core sg iTCO_wdt
> > iTCO_vendor_support ioatdma dca i7core_edac edac_core shpchp ext4 mbcache
> > jbd2 megaraid_sas(U) sd_mod crc_t10dif ahci dm_mod [last unloaded:
> > scsi_wait_scan]
> > Dec  6 20:27:55 localhost kernel: Pid: 2898, comm: nfsd Not tainted
> > 2.6.32-131.21.1.el6.x86_64 #1
> > Dec  6 20:27:55 localhost kernel: Call Trace:
> > Dec  6 20:27:55 localhost kernel: <IRQ>  [<ffffffff81067097>] ?
> > warn_slowpath_common+0x87/0xc0
> > Dec  6 20:27:55 localhost kernel: [<ffffffff8106f6da>] ?
> > __do_softirq+0x11a/0x1d0
> > Dec  6 20:27:55 localhost kernel: [<ffffffff81067186>] ?
> > warn_slowpath_fmt+0x46/0x50
> > Dec  6 20:27:55 localhost kernel: [<ffffffff8100c2cc>] ?
> > call_softirq+0x1c/0x30
> > Dec  6 20:27:55 localhost kernel: [<ffffffff8100dfcf>] ?
> > handle_irq+0x8f/0xa0
> > Dec  6 20:27:55 localhost kernel: [<ffffffff814e310c>] ? do_IRQ+0x6c/0xf0
> > Dec  6 20:27:55 localhost kernel: [<ffffffff8100bad3>] ?
> > ret_from_intr+0x0/0x11
> > Dec  6 20:27:55 localhost kernel: <EOI>  [<ffffffff8115b80f>] ?
> > kmem_cache_free+0xbf/0x2b0
> > Dec  6 20:27:55 localhost kernel: [<ffffffff811a2542>] ?
> > free_buffer_head+0x22/0x50
> > Dec  6 20:27:55 localhost kernel: [<ffffffff811a2919>] ?
> > try_to_free_buffers+0x79/0xc0
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa0259a9c>] ?
> > xfs_vm_releasepage+0xbc/0x130 [xfs]
> > Dec  6 20:27:55 localhost kernel: [<ffffffff8110c6c0>] ?
> > try_to_release_page+0x30/0x60
> > Dec  6 20:27:55 localhost kernel: [<ffffffff811262c1>] ?
> > shrink_page_list.clone.0+0x4f1/0x5c0
> > Dec  6 20:27:55 localhost kernel: [<ffffffff81126688>] ?
> > shrink_inactive_list+0x2f8/0x740
> > Dec  6 20:27:55 localhost kernel: [<ffffffff8111f7f6>] ?
> > free_pcppages_bulk+0x2b6/0x390
> > Dec  6 20:27:55 localhost kernel: [<ffffffff811278df>] ?
> > shrink_zone+0x38f/0x520
> > Dec  6 20:27:55 localhost kernel: [<ffffffff811646f8>] ?
> > __mem_cgroup_uncharge_common+0x198/0x270
> > Dec  6 20:27:55 localhost kernel: [<ffffffff81128684>] ?
> > zone_reclaim+0x354/0x410
> > Dec  6 20:27:55 localhost kernel: [<ffffffff811292c0>] ?
> > isolate_pages_global+0x0/0x380
> > Dec  6 20:27:55 localhost kernel: [<ffffffff8111ebf4>] ?
> > get_page_from_freelist+0x694/0x820
> > Dec  6 20:27:55 localhost kernel: [<ffffffff81126882>] ?
> > shrink_inactive_list+0x4f2/0x740
> > Dec  6 20:27:55 localhost kernel: [<ffffffff8111fb01>] ?
> > __alloc_pages_nodemask+0x111/0x8b0
> > Dec  6 20:27:55 localhost kernel: [<ffffffff8110d17e>] ?
> > find_get_page+0x1e/0xa0
> > Dec  6 20:27:55 localhost kernel: [<ffffffff8110e307>] ?
> > find_lock_page+0x37/0x80
> > Dec  6 20:27:55 localhost kernel: [<ffffffff811546da>] ?
> > alloc_pages_current+0xaa/0x110
> > Dec  6 20:27:55 localhost kernel: [<ffffffff8110d6b7>] ?
> > __page_cache_alloc+0x87/0x90
> > Dec  6 20:27:55 localhost kernel: [<ffffffff8110e45f>] ?
> > find_or_create_page+0x4f/0xb0
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa025b945>] ?
> > _xfs_buf_lookup_pages+0x145/0x360 [xfs]
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa025b2ab>] ?
> > _xfs_buf_initialize+0xcb/0x140 [xfs]
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa025cb57>] ?
> > xfs_buf_get+0x77/0x1b0 [xfs]
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa025ccbc>] ?
> > xfs_buf_read+0x2c/0x100 [xfs]
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa0250e39>] ?
> > xfs_trans_read_buf+0x219/0x440 [xfs]
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa021efde>] ?
> > xfs_btree_read_buf_block+0x5e/0xc0 [xfs]
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa021f6d4>] ?
> > xfs_btree_lookup_get_block+0x84/0xf0 [xfs]
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa021d64c>] ?
> > xfs_btree_ptr_offset+0x4c/0x90 [xfs]
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa021fd5f>] ?
> > xfs_btree_lookup+0xbf/0x470 [xfs]
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa0209cfa>] ?
> > xfs_alloc_ag_vextent_near+0x98a/0xb70 [xfs]
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa0250afd>] ?
> > xfs_trans_log_buf+0x9d/0xe0 [xfs]
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa021348f>] ?
> > xfs_bmbt_lookup_eq+0x1f/0x30 [xfs]
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa021a2e4>] ?
> > xfs_bmap_add_extent_delay_real+0xe54/0x18d0 [xfs]
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa025737a>] ?
> > kmem_zone_alloc+0x9a/0xe0 [xfs]
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa01ff009>] ?
> > xfs_trans_mod_dquot_byino+0x79/0xd0 [xfs]
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa021b15f>] ?
> > xfs_bmap_add_extent+0x3ff/0x420 [xfs]
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa021ce7a>] ?
> > xfs_bmbt_init_cursor+0x4a/0x150 [xfs]
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa021bc94>] ?
> > xfs_bmapi+0xb14/0x11a0 [xfs]
> > Dec  6 20:27:55 localhost kernel: [<ffffffff814dc986>] ?
> > down_write+0x16/0x40
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa023ddd5>] ?
> > xfs_iomap_write_allocate+0x1c5/0x3b0 [xfs]
> > Dec  6 20:27:55 localhost kernel: [<ffffffff81248a9e>] ?
> > generic_make_request+0x21e/0x5b0
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa023eb19>] ?
> > xfs_iomap+0x389/0x440 [xfs]
> > Dec  6 20:27:55 localhost kernel: [<ffffffff8119b6ac>] ?
> > __mark_inode_dirty+0x6c/0x160
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa0257f4d>] ?
> > xfs_map_blocks+0x2d/0x40 [xfs]
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa0259588>] ?
> > xfs_page_state_convert+0x2f8/0x750 [xfs]
> > Dec  6 20:27:55 localhost kernel: [<ffffffff81268505>] ?
> > radix_tree_gang_lookup_tag_slot+0x95/0xe0
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa0259b96>] ?
> > xfs_vm_writepage+0x86/0x170 [xfs]
> > Dec  6 20:27:55 localhost kernel: [<ffffffff81120d67>] ?
> > __writepage+0x17/0x40
> > Dec  6 20:27:55 localhost kernel: [<ffffffff811220f9>] ?
> > write_cache_pages+0x1c9/0x4a0
> > Dec  6 20:27:55 localhost kernel: [<ffffffff81120d50>] ?
> > __writepage+0x0/0x40
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa023ab93>] ?
> > xfs_iflush+0x203/0x210 [xfs]
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa025af9f>] ?
> > xfs_bdwrite+0x5f/0xa0 [xfs]
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa024fe99>] ?
> > xfs_trans_unlocked_item+0x39/0x60 [xfs]
> > Dec  6 20:27:55 localhost kernel: [<ffffffff811223f4>] ?
> > generic_writepages+0x24/0x30
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa025898e>] ?
> > xfs_vm_writepages+0x5e/0x80 [xfs]
> > Dec  6 20:27:55 localhost kernel: [<ffffffff81122421>] ?
> > do_writepages+0x21/0x40
> > Dec  6 20:27:55 localhost kernel: [<ffffffff8119bc8d>] ?
> > writeback_single_inode+0xdd/0x2c0
> > Dec  6 20:27:55 localhost kernel: [<ffffffff8119c08e>] ?
> > writeback_sb_inodes+0xce/0x180
> > Dec  6 20:27:55 localhost kernel: [<ffffffff8119c1eb>] ?
> > writeback_inodes_wb+0xab/0x1b0
> > Dec  6 20:27:55 localhost kernel: [<ffffffff8112181e>] ?
> > balance_dirty_pages+0x21e/0x4d0
> > Dec  6 20:27:55 localhost kernel: [<ffffffff811a3851>] ?
> > mark_buffer_dirty+0x61/0xa0
> > Dec  6 20:27:55 localhost kernel: [<ffffffff81121b34>] ?
> > balance_dirty_pages_ratelimited_nr+0x64/0x70
> > Dec  6 20:27:55 localhost kernel: [<ffffffff8110dd23>] ?
> > generic_file_buffered_write+0x1c3/0x2a0
> > Dec  6 20:27:55 localhost kernel: [<ffffffff8106dcb7>] ?
> > current_fs_time+0x27/0x30
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa0261e4f>] ?
> > xfs_write+0x76f/0xb70 [xfs]
> > Dec  6 20:27:55 localhost kernel: [<ffffffff814174b5>] ?
> > memcpy_toiovec+0x55/0x80
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa025d800>] ?
> > xfs_file_aio_write+0x0/0x70 [xfs]
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa025d861>] ?
> > xfs_file_aio_write+0x61/0x70 [xfs]
> > Dec  6 20:27:55 localhost kernel: [<ffffffff811723bb>] ?
> > do_sync_readv_writev+0xfb/0x140
> > Dec  6 20:27:55 localhost kernel: [<ffffffff8118ae9d>] ?
> > d_obtain_alias+0x4d/0x160
> > Dec  6 20:27:55 localhost kernel: [<ffffffff8108e120>] ?
> > autoremove_wake_function+0x0/0x40
> > Dec  6 20:27:55 localhost kernel: [<ffffffff812056b6>] ?
> > security_task_setgroups+0x16/0x20
> > Dec  6 20:27:55 localhost kernel: [<ffffffff81205356>] ?
> > security_file_permission+0x16/0x20
> > Dec  6 20:27:55 localhost kernel: [<ffffffff8117347f>] ?
> > do_readv_writev+0xcf/0x1f0
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa047f852>] ?
> > nfsd_setuser_and_check_port+0x62/0xb0 [nfsd]
> > Dec  6 20:27:55 localhost kernel: [<ffffffff811735e6>] ?
> > vfs_writev+0x46/0x60
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa04813d7>] ?
> > nfsd_vfs_write+0x107/0x430 [nfsd]
> > Dec  6 20:27:55 localhost kernel: [<ffffffff8116fe22>] ?
> > dentry_open+0x52/0xc0
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa04839fe>] ?
> > nfsd_open+0x13e/0x210 [nfsd]
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa0483e87>] ?
> > nfsd_write+0xe7/0x100 [nfsd]
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa048b7df>] ?
> > nfsd3_proc_write+0xaf/0x140 [nfsd]
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa047c43e>] ?
> > nfsd_dispatch+0xfe/0x240 [nfsd]
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa03f24d4>] ?
> > svc_process_common+0x344/0x640 [sunrpc]
> > Dec  6 20:27:55 localhost kernel: [<ffffffff8105dbc0>] ?
> > default_wake_function+0x0/0x20
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa03f2b10>] ?
> > svc_process+0x110/0x160 [sunrpc]
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa047cb62>] ? nfsd+0xc2/0x160
> > [nfsd]
> > Dec  6 20:27:55 localhost kernel: [<ffffffffa047caa0>] ? nfsd+0x0/0x160
> > [nfsd]
> > Dec  6 20:27:55 localhost kernel: [<ffffffff8108ddb6>] ?
> kthread+0x96/0xa0
> > Dec  6 20:27:55 localhost kernel: [<ffffffff8100c1ca>] ?
> child_rip+0xa/0x20
> > Dec  6 20:27:55 localhost kernel: [<ffffffff8108dd20>] ? kthread+0x0/0xa0
> > Dec  6 20:27:55 localhost kernel: [<ffffffff8100c1c0>] ?
> child_rip+0x0/0x20
> > Dec  6 20:27:55 localhost kernel: ---[ end trace e8b62253d4084e2b ]---
> >
> > --
> > Ryan C. England
> > Corvid Technologies <http://www.corvidtec.com/>
> > office: 704-799-6944 x158
> > cell:    980-521-2297
>
> > _______________________________________________
> > xfs mailing list
> > xfs@oss.sgi.com
> > http://oss.sgi.com/mailman/listinfo/xfs
>
> ---end quoted text---
>



-- 
Ryan C. England
Corvid Technologies <http://www.corvidtec.com/>
office: 704-799-6944 x158
cell:    980-521-2297

--0015174bf0707263fd04b3aad341
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Chris,<div><br></div><div>Thanks for the reply. =A0You have been a great he=
lp.</div><div><br></div><div>Do you know if these changes were implemented =
any farther back than 3.2? =A0I wouldn&#39;t feel comfortable running a rel=
ease candidate kernel in a production environment.</div>
<div><br></div><div>Thanks again<br><br><div class=3D"gmail_quote">On Fri, =
Dec 9, 2011 at 6:55 AM, Christoph Hellwig <span dir=3D"ltr">&lt;<a href=3D"=
mailto:hch@infradead.org">hch@infradead.org</a>&gt;</span> wrote:<br><block=
quote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc=
 solid;padding-left:1ex;">
<div class=3D"im">On Thu, Dec 08, 2011 at 01:03:51PM -0500, Ryan C. England=
 wrote:<br>
&gt; I am looking for assistance on XFS which is why I have joined this mai=
ling<br>
&gt; list. =A0I&#39;m receiving a stack overflow on our file server. =A0The=
 server is<br>
&gt; running Scientific Linux 6.1 with the following kernel,<br>
&gt; 2.6.32-131.21.1.el6.x86_64.<br>
&gt;<br>
&gt; This is causing random reboots which is more annoying than anything. =
=A0I<br>
&gt; found a couple of links in the archives but wasn&#39;t quite sure how =
to apply<br>
&gt; this patch. =A0I can provide whatever information necessary in order f=
or<br>
&gt; assistance in troubleshooting.<br>
<br>
</div>It&#39;s really mostly an issue with the VM page reclaim and writebac=
k<br>
code. =A0The kernel still has the old balance dirty pages code which calls<=
br>
into writeback code from the stack of the write system call, which<br>
already comes from NFSD with massive amounts of stack used. =A0Then<br>
the writeback code calls into XFS to write data out, then you get the<br>
full XFS btree code, which then ends up in kmalloc and memory reclaim.<br>
<br>
You probably have only a third of the stack actually used by XFS, the<br>
rest is from NFSD/writeback code and page reclaim. =A0I don&#39;t think any=
<br>
of this is easily fixable in a 2.6.32 codebase. =A0Current mainline 3.2-rc<=
br>
now has the I/O-less balance dirty pages which will basically split the<br>
stack footprint in half, but it&#39;s an invasive change to the writeback<b=
r>
code that isn&#39;t easily backportable.<br>
<div><div class=3D"h5"><br>
&gt; Dec =A06 20:27:55 localhost kernel: ------------[ cut here ]----------=
--<br>
&gt; Dec =A06 20:27:55 localhost kernel: WARNING: at arch/x86/kernel/irq_64=
.c:47<br>
&gt; handle_irq+0x8f/0xa0() (Not tainted)<br>
&gt; Dec =A06 20:27:55 localhost kernel: Hardware name: X8DTH-i/6/iF/6F<br>
&gt; Dec =A06 20:27:55 localhost kernel: do_IRQ: nfsd near stack overflow<b=
r>
&gt; (cur:ffff880622208000,sp:ffff880622208160)<br>
&gt; Dec =A06 20:27:55 localhost kernel: Modules linked in: mpt2sas<br>
&gt; scsi_transport_sas raid_class mptctl mptbase nfsd lockd nfs_acl auth_r=
pcgss<br>
&gt; autofs4 sunrpc cpufreq_ondemand acpi_cpufreq freq_table ip6t_REJECT<br=
>
&gt; nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter=
<br>
&gt; ip6_tables ipv6 xfs exportfs dm_mirror dm_region_hash dm_log ses enclo=
sure<br>
&gt; ixgbe mdio microcode igb serio_raw ghes hed i2c_i801 i2c_core sg iTCO_=
wdt<br>
&gt; iTCO_vendor_support ioatdma dca i7core_edac edac_core shpchp ext4 mbca=
che<br>
&gt; jbd2 megaraid_sas(U) sd_mod crc_t10dif ahci dm_mod [last unloaded:<br>
&gt; scsi_wait_scan]<br>
&gt; Dec =A06 20:27:55 localhost kernel: Pid: 2898, comm: nfsd Not tainted<=
br>
&gt; 2.6.32-131.21.1.el6.x86_64 #1<br>
&gt; Dec =A06 20:27:55 localhost kernel: Call Trace:<br>
&gt; Dec =A06 20:27:55 localhost kernel: &lt;IRQ&gt; =A0[&lt;ffffffff810670=
97&gt;] ?<br>
&gt; warn_slowpath_common+0x87/0xc0<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff8106f6da&gt;] ?<br>
&gt; __do_softirq+0x11a/0x1d0<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff81067186&gt;] ?<br>
&gt; warn_slowpath_fmt+0x46/0x50<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff8100c2cc&gt;] ?<br>
&gt; call_softirq+0x1c/0x30<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff8100dfcf&gt;] ?<br>
&gt; handle_irq+0x8f/0xa0<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff814e310c&gt;] ? do_IR=
Q+0x6c/0xf0<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff8100bad3&gt;] ?<br>
&gt; ret_from_intr+0x0/0x11<br>
&gt; Dec =A06 20:27:55 localhost kernel: &lt;EOI&gt; =A0[&lt;ffffffff8115b8=
0f&gt;] ?<br>
&gt; kmem_cache_free+0xbf/0x2b0<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff811a2542&gt;] ?<br>
&gt; free_buffer_head+0x22/0x50<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff811a2919&gt;] ?<br>
&gt; try_to_free_buffers+0x79/0xc0<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa0259a9c&gt;] ?<br>
&gt; xfs_vm_releasepage+0xbc/0x130 [xfs]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff8110c6c0&gt;] ?<br>
&gt; try_to_release_page+0x30/0x60<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff811262c1&gt;] ?<br>
&gt; shrink_page_list.clone.0+0x4f1/0x5c0<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff81126688&gt;] ?<br>
&gt; shrink_inactive_list+0x2f8/0x740<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff8111f7f6&gt;] ?<br>
&gt; free_pcppages_bulk+0x2b6/0x390<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff811278df&gt;] ?<br>
&gt; shrink_zone+0x38f/0x520<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff811646f8&gt;] ?<br>
&gt; __mem_cgroup_uncharge_common+0x198/0x270<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff81128684&gt;] ?<br>
&gt; zone_reclaim+0x354/0x410<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff811292c0&gt;] ?<br>
&gt; isolate_pages_global+0x0/0x380<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff8111ebf4&gt;] ?<br>
&gt; get_page_from_freelist+0x694/0x820<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff81126882&gt;] ?<br>
&gt; shrink_inactive_list+0x4f2/0x740<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff8111fb01&gt;] ?<br>
&gt; __alloc_pages_nodemask+0x111/0x8b0<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff8110d17e&gt;] ?<br>
&gt; find_get_page+0x1e/0xa0<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff8110e307&gt;] ?<br>
&gt; find_lock_page+0x37/0x80<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff811546da&gt;] ?<br>
&gt; alloc_pages_current+0xaa/0x110<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff8110d6b7&gt;] ?<br>
&gt; __page_cache_alloc+0x87/0x90<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff8110e45f&gt;] ?<br>
&gt; find_or_create_page+0x4f/0xb0<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa025b945&gt;] ?<br>
&gt; _xfs_buf_lookup_pages+0x145/0x360 [xfs]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa025b2ab&gt;] ?<br>
&gt; _xfs_buf_initialize+0xcb/0x140 [xfs]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa025cb57&gt;] ?<br>
&gt; xfs_buf_get+0x77/0x1b0 [xfs]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa025ccbc&gt;] ?<br>
&gt; xfs_buf_read+0x2c/0x100 [xfs]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa0250e39&gt;] ?<br>
&gt; xfs_trans_read_buf+0x219/0x440 [xfs]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa021efde&gt;] ?<br>
&gt; xfs_btree_read_buf_block+0x5e/0xc0 [xfs]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa021f6d4&gt;] ?<br>
&gt; xfs_btree_lookup_get_block+0x84/0xf0 [xfs]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa021d64c&gt;] ?<br>
&gt; xfs_btree_ptr_offset+0x4c/0x90 [xfs]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa021fd5f&gt;] ?<br>
&gt; xfs_btree_lookup+0xbf/0x470 [xfs]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa0209cfa&gt;] ?<br>
&gt; xfs_alloc_ag_vextent_near+0x98a/0xb70 [xfs]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa0250afd&gt;] ?<br>
&gt; xfs_trans_log_buf+0x9d/0xe0 [xfs]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa021348f&gt;] ?<br>
&gt; xfs_bmbt_lookup_eq+0x1f/0x30 [xfs]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa021a2e4&gt;] ?<br>
&gt; xfs_bmap_add_extent_delay_real+0xe54/0x18d0 [xfs]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa025737a&gt;] ?<br>
&gt; kmem_zone_alloc+0x9a/0xe0 [xfs]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa01ff009&gt;] ?<br>
&gt; xfs_trans_mod_dquot_byino+0x79/0xd0 [xfs]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa021b15f&gt;] ?<br>
&gt; xfs_bmap_add_extent+0x3ff/0x420 [xfs]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa021ce7a&gt;] ?<br>
&gt; xfs_bmbt_init_cursor+0x4a/0x150 [xfs]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa021bc94&gt;] ?<br>
&gt; xfs_bmapi+0xb14/0x11a0 [xfs]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff814dc986&gt;] ?<br>
&gt; down_write+0x16/0x40<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa023ddd5&gt;] ?<br>
&gt; xfs_iomap_write_allocate+0x1c5/0x3b0 [xfs]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff81248a9e&gt;] ?<br>
&gt; generic_make_request+0x21e/0x5b0<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa023eb19&gt;] ?<br>
&gt; xfs_iomap+0x389/0x440 [xfs]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff8119b6ac&gt;] ?<br>
&gt; __mark_inode_dirty+0x6c/0x160<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa0257f4d&gt;] ?<br>
&gt; xfs_map_blocks+0x2d/0x40 [xfs]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa0259588&gt;] ?<br>
&gt; xfs_page_state_convert+0x2f8/0x750 [xfs]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff81268505&gt;] ?<br>
&gt; radix_tree_gang_lookup_tag_slot+0x95/0xe0<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa0259b96&gt;] ?<br>
&gt; xfs_vm_writepage+0x86/0x170 [xfs]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff81120d67&gt;] ?<br>
&gt; __writepage+0x17/0x40<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff811220f9&gt;] ?<br>
&gt; write_cache_pages+0x1c9/0x4a0<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff81120d50&gt;] ?<br>
&gt; __writepage+0x0/0x40<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa023ab93&gt;] ?<br>
&gt; xfs_iflush+0x203/0x210 [xfs]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa025af9f&gt;] ?<br>
&gt; xfs_bdwrite+0x5f/0xa0 [xfs]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa024fe99&gt;] ?<br>
&gt; xfs_trans_unlocked_item+0x39/0x60 [xfs]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff811223f4&gt;] ?<br>
&gt; generic_writepages+0x24/0x30<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa025898e&gt;] ?<br>
&gt; xfs_vm_writepages+0x5e/0x80 [xfs]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff81122421&gt;] ?<br>
&gt; do_writepages+0x21/0x40<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff8119bc8d&gt;] ?<br>
&gt; writeback_single_inode+0xdd/0x2c0<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff8119c08e&gt;] ?<br>
&gt; writeback_sb_inodes+0xce/0x180<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff8119c1eb&gt;] ?<br>
&gt; writeback_inodes_wb+0xab/0x1b0<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff8112181e&gt;] ?<br>
&gt; balance_dirty_pages+0x21e/0x4d0<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff811a3851&gt;] ?<br>
&gt; mark_buffer_dirty+0x61/0xa0<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff81121b34&gt;] ?<br>
&gt; balance_dirty_pages_ratelimited_nr+0x64/0x70<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff8110dd23&gt;] ?<br>
&gt; generic_file_buffered_write+0x1c3/0x2a0<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff8106dcb7&gt;] ?<br>
&gt; current_fs_time+0x27/0x30<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa0261e4f&gt;] ?<br>
&gt; xfs_write+0x76f/0xb70 [xfs]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff814174b5&gt;] ?<br>
&gt; memcpy_toiovec+0x55/0x80<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa025d800&gt;] ?<br>
&gt; xfs_file_aio_write+0x0/0x70 [xfs]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa025d861&gt;] ?<br>
&gt; xfs_file_aio_write+0x61/0x70 [xfs]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff811723bb&gt;] ?<br>
&gt; do_sync_readv_writev+0xfb/0x140<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff8118ae9d&gt;] ?<br>
&gt; d_obtain_alias+0x4d/0x160<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff8108e120&gt;] ?<br>
&gt; autoremove_wake_function+0x0/0x40<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff812056b6&gt;] ?<br>
&gt; security_task_setgroups+0x16/0x20<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff81205356&gt;] ?<br>
&gt; security_file_permission+0x16/0x20<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff8117347f&gt;] ?<br>
&gt; do_readv_writev+0xcf/0x1f0<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa047f852&gt;] ?<br>
&gt; nfsd_setuser_and_check_port+0x62/0xb0 [nfsd]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff811735e6&gt;] ?<br>
&gt; vfs_writev+0x46/0x60<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa04813d7&gt;] ?<br>
&gt; nfsd_vfs_write+0x107/0x430 [nfsd]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff8116fe22&gt;] ?<br>
&gt; dentry_open+0x52/0xc0<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa04839fe&gt;] ?<br>
&gt; nfsd_open+0x13e/0x210 [nfsd]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa0483e87&gt;] ?<br>
&gt; nfsd_write+0xe7/0x100 [nfsd]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa048b7df&gt;] ?<br>
&gt; nfsd3_proc_write+0xaf/0x140 [nfsd]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa047c43e&gt;] ?<br>
&gt; nfsd_dispatch+0xfe/0x240 [nfsd]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa03f24d4&gt;] ?<br>
&gt; svc_process_common+0x344/0x640 [sunrpc]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff8105dbc0&gt;] ?<br>
&gt; default_wake_function+0x0/0x20<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa03f2b10&gt;] ?<br>
&gt; svc_process+0x110/0x160 [sunrpc]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa047cb62&gt;] ? nfsd+=
0xc2/0x160<br>
&gt; [nfsd]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffffa047caa0&gt;] ? nfsd+=
0x0/0x160<br>
&gt; [nfsd]<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff8108ddb6&gt;] ? kthre=
ad+0x96/0xa0<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff8100c1ca&gt;] ? child=
_rip+0xa/0x20<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff8108dd20&gt;] ? kthre=
ad+0x0/0xa0<br>
&gt; Dec =A06 20:27:55 localhost kernel: [&lt;ffffffff8100c1c0&gt;] ? child=
_rip+0x0/0x20<br>
&gt; Dec =A06 20:27:55 localhost kernel: ---[ end trace e8b62253d4084e2b ]-=
--<br>
&gt;<br>
&gt; --<br>
&gt; Ryan C. England<br>
</div></div>&gt; Corvid Technologies &lt;<a href=3D"http://www.corvidtec.co=
m/" target=3D"_blank">http://www.corvidtec.com/</a>&gt;<br>
<div class=3D"im">&gt; office: <a href=3D"tel:704-799-6944%20x158" value=3D=
"+17047996944">704-799-6944 x158</a><br>
&gt; cell: =A0 =A0<a href=3D"tel:980-521-2297" value=3D"+19805212297">980-5=
21-2297</a><br>
<br>
</div>&gt; _______________________________________________<br>
&gt; xfs mailing list<br>
&gt; <a href=3D"mailto:xfs@oss.sgi.com">xfs@oss.sgi.com</a><br>
&gt; <a href=3D"http://oss.sgi.com/mailman/listinfo/xfs" target=3D"_blank">=
http://oss.sgi.com/mailman/listinfo/xfs</a><br>
<br>
---end quoted text---<br>
</blockquote></div><br><br clear=3D"all"><div><br></div>-- <br><div>Ryan C.=
 England</div><div><a href=3D"http://www.corvidtec.com/" target=3D"_blank">=
Corvid Technologies</a></div>office: 704-799-6944 x158<br>cell:=A0=A0=A0 98=
0-521-2297<br>

</div>

--0015174bf0707263fd04b3aad341--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
