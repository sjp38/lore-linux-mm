Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 99C746B0032
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 15:59:19 -0400 (EDT)
Subject: =?utf-8?q?Re=3A_=5Bpatch_0=2F7=5D_improve_memcg_oom_killer_robustness_v2?=
Date: Mon, 09 Sep 2013 21:59:17 +0200
From: "azurIt" <azurit@pobox.sk>
References: <1375549200-19110-1-git-send-email-hannes@cmpxchg.org>, <20130803170831.GB23319@cmpxchg.org>, <20130830215852.3E5D3D66@pobox.sk>, <20130902123802.5B8E8CB1@pobox.sk>, <20130903204850.GA1412@cmpxchg.org>, <20130904101852.58E70042@pobox.sk>, <20130905115430.GB856@cmpxchg.org>, <20130909151010.3A3CBC6A@pobox.sk> <20130909172849.GG856@cmpxchg.org>
In-Reply-To: <20130909172849.GG856@cmpxchg.org>
MIME-Version: 1.0
Message-Id: <20130909215917.96932098@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?Johannes_Weiner?= <hannes@cmpxchg.org>
Cc: =?utf-8?q?Andrew_Morton?= <akpm@linux-foundation.org>, =?utf-8?q?Michal_Hocko?= <mhocko@suse.cz>, =?utf-8?q?David_Rientjes?= <rientjes@google.com>, =?utf-8?q?KAMEZAWA_Hiroyuki?= <kamezawa.hiroyu@jp.fujitsu.com>, =?utf-8?q?KOSAKI_Motohiro?= <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

>On Mon, Sep 09, 2013 at 03:10:10PM +0200, azurIt wrote:
>> >Hi azur,
>> >
>> >On Wed, Sep 04, 2013 at 10:18:52AM +0200, azurIt wrote:
>> >> > CC: "Andrew Morton" <akpm@linux-foundation.org>, "Michal Hocko" <mhocko@suse.cz>, "David Rientjes" <rientjes@google.com>, "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>, "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
>> >> >Hello azur,
>> >> >
>> >> >On Mon, Sep 02, 2013 at 12:38:02PM +0200, azurIt wrote:
>> >> >> >>Hi azur,
>> >> >> >>
>> >> >> >>here is the x86-only rollup of the series for 3.2.
>> >> >> >>
>> >> >> >>Thanks!
>> >> >> >>Johannes
>> >> >> >>---
>> >> >> >
>> >> >> >
>> >> >> >Johannes,
>> >> >> >
>> >> >> >unfortunately, one problem arises: I have (again) cgroup which cannot be deleted :( it's a user who had very high memory usage and was reaching his limit very often. Do you need any info which i can gather now?
>> >> >
>> >> >Did the OOM killer go off in this group?
>> >> >
>> >> >Was there a warning in the syslog ("Fixing unhandled memcg OOM
>> >> >context")?
>> >> 
>> >> 
>> >> 
>> >> Ok, i see this message several times in my syslog logs, one of them is also for this unremovable cgroup (but maybe all of them cannot be removed, should i try?). Example of the log is here (don't know where exactly it starts and ends so here is the full kernel log):
>> >> http://watchdog.sk/lkml/oom_syslog.gz
>> >There is an unfinished OOM invocation here:
>> >
>> >  Aug 22 13:15:21 server01 kernel: [1251422.715112] Fixing unhandled memcg OOM context set up from:
>> >  Aug 22 13:15:21 server01 kernel: [1251422.715191]  [<ffffffff811105c2>] T.1154+0x622/0x8f0
>> >  Aug 22 13:15:21 server01 kernel: [1251422.715274]  [<ffffffff8111153e>] mem_cgroup_cache_charge+0xbe/0xe0
>> >  Aug 22 13:15:21 server01 kernel: [1251422.715357]  [<ffffffff810cf31c>] add_to_page_cache_locked+0x4c/0x140
>> >  Aug 22 13:15:21 server01 kernel: [1251422.715443]  [<ffffffff810cf432>] add_to_page_cache_lru+0x22/0x50
>> >  Aug 22 13:15:21 server01 kernel: [1251422.715526]  [<ffffffff810cfdd3>] find_or_create_page+0x73/0xb0
>> >  Aug 22 13:15:21 server01 kernel: [1251422.715608]  [<ffffffff811493ba>] __getblk+0xea/0x2c0
>> >  Aug 22 13:15:21 server01 kernel: [1251422.715692]  [<ffffffff8114ca73>] __bread+0x13/0xc0
>> >  Aug 22 13:15:21 server01 kernel: [1251422.715774]  [<ffffffff81196968>] ext3_get_branch+0x98/0x140
>> >  Aug 22 13:15:21 server01 kernel: [1251422.715859]  [<ffffffff81197557>] ext3_get_blocks_handle+0xd7/0xdc0
>> >  Aug 22 13:15:21 server01 kernel: [1251422.715942]  [<ffffffff81198304>] ext3_get_block+0xc4/0x120
>> >  Aug 22 13:15:21 server01 kernel: [1251422.716023]  [<ffffffff81155c3a>] do_mpage_readpage+0x38a/0x690
>> >  Aug 22 13:15:21 server01 kernel: [1251422.716107]  [<ffffffff81155f8f>] mpage_readpage+0x4f/0x70
>> >  Aug 22 13:15:21 server01 kernel: [1251422.716188]  [<ffffffff811973a8>] ext3_readpage+0x28/0x60
>> >  Aug 22 13:15:21 server01 kernel: [1251422.716268]  [<ffffffff810cfa48>] filemap_fault+0x308/0x560
>> >  Aug 22 13:15:21 server01 kernel: [1251422.716350]  [<ffffffff810ef898>] __do_fault+0x78/0x5a0
>> >  Aug 22 13:15:21 server01 kernel: [1251422.716433]  [<ffffffff810f2ab4>] handle_pte_fault+0x84/0x940
>> >
>> >__getblk() has this weird loop where it tries to instantiate the page,
>> >frees memory on failure, then retries.  If the memcg goes OOM, the OOM
>> >path might be entered multiple times and each time leak the memcg
>> >reference of the respective previous OOM invocation.
>> >
>> >There are a few more find_or_create() sites that do not propagate an
>> >error and it's incredibly hard to find out whether they are even taken
>> >during a page fault.  It's not practical to annotate them all with
>> >memcg OOM toggles, so let's just catch all OOM contexts at the end of
>> >handle_mm_fault() and clear them if !VM_FAULT_OOM instead of treating
>> >this like an error.
>> >
>> >azur, here is a patch on top of your modified 3.2.  Note that Michal
>> >might be onto something and we are looking at multiple issues here,
>> >but the log excert above suggests this fix is required either way.
>> 
>> 
>> 
>> 
>> Johannes, is this still up to date? Thank you.
>
>No, please use the following on top of 3.2 (i.e. full replacement, not
>incremental to what you have):



Unfortunately it didn't compile:




  LD      vmlinux.o
  MODPOST vmlinux.o
WARNING: modpost: Found 4924 section mismatch(es).
To see full details build your kernel with:
'make CONFIG_DEBUG_SECTION_MISMATCH=y'
  GEN     .version
  CHK     include/generated/compile.h
  UPD     include/generated/compile.h
  CC      init/version.o
  LD      init/built-in.o
  LD      .tmp_vmlinux1
arch/x86/built-in.o: In function `do_page_fault':
(.text+0x26a77): undefined reference to `handle_mm_fault'
mm/built-in.o: In function `fixup_user_fault':
(.text+0x224d3): undefined reference to `handle_mm_fault'
mm/built-in.o: In function `__get_user_pages':
(.text+0x24a0f): undefined reference to `handle_mm_fault'
make: *** [.tmp_vmlinux1] Error 1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
