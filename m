Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id F0C136B0253
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 08:21:43 -0400 (EDT)
Received: by oiao187 with SMTP id o187so8235202oia.2
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 05:21:43 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id ny8si1655612oeb.25.2015.10.13.05.21.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 13 Oct 2015 05:21:42 -0700 (PDT)
Subject: Re: Silent hang up caused by pages being not scanned?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201510031502.BJD59536.HFJMtQOOLFFVSO@I-love.SAKURA.ne.jp>
	<201510062351.JHJ57310.VFQLFHFOJtSMOO@I-love.SAKURA.ne.jp>
	<201510121543.EJF21858.LtJFHOOOSQVMFF@I-love.SAKURA.ne.jp>
	<201510130025.EJF21331.FFOQJtVOMLFHSO@I-love.SAKURA.ne.jp>
	<CA+55aFwapaED7JV6zm-NVkP-jKie+eQ1vDXWrKD=SkbshZSgmw@mail.gmail.com>
In-Reply-To: <CA+55aFwapaED7JV6zm-NVkP-jKie+eQ1vDXWrKD=SkbshZSgmw@mail.gmail.com>
Message-Id: <201510132121.GDE13044.FOSHLJOMFOtQVF@I-love.SAKURA.ne.jp>
Date: Tue, 13 Oct 2015 21:21:25 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: mhocko@kernel.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

Linus Torvalds wrote:
> On Mon, Oct 12, 2015 at 8:25 AM, Tetsuo Handa
> <penguin-kernel@i-love.sakura.ne.jp> wrote:
> >
> > I examined this hang up using additional debug printk() patch. And it was
> > observed that when this silent hang up occurs, zone_reclaimable() called from
> > shrink_zones() called from a __GFP_FS memory allocation request is returning
> > true forever. Since the __GFP_FS memory allocation request can never call
> > out_of_memory() due to did_some_progree > 0, the system will silently hang up
> > with 100% CPU usage.
> 
> I wouldn't blame the zones_reclaimable() logic itself, but yeah, that looks bad.
> 

I compared "hang up after the OOM killer is invoked" and "hang up before
the OOM killer is invoked" by always printing the values.

 			}
 			reclaimable = true;
 		}
+		else if (dump_target_pid == current->pid) {
+			printk(KERN_INFO "(ACTIVE_FILE=%lu+INACTIVE_FILE=%lu",
+			       zone_page_state(zone, NR_ACTIVE_FILE),
+			       zone_page_state(zone, NR_INACTIVE_FILE));
+			if (get_nr_swap_pages() > 0)
+				printk(KERN_CONT "+ACTIVE_ANON=%lu+INACTIVE_ANON=%lu",
+				       zone_page_state(zone, NR_ACTIVE_ANON),
+				       zone_page_state(zone, NR_INACTIVE_ANON));
+			printk(KERN_CONT ") * 6 > PAGES_SCANNED=%lu\n",
+			       zone_page_state(zone, NR_PAGES_SCANNED));
+		}
 	}
 
 	/*

For the former case, most of trials showed that

  (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0

. Sometimes PAGES_SCANNED > 0 (as grep'ed below), but ACTIVE_FILE and
INACTIVE_FILE seems to be always 0.

----------
[  195.905057] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=2
[  195.927430] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=2
[  206.317088] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=2
[  206.338007] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=2
[  216.723776] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=2
[  216.744618] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=2
[  227.129653] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=2
[  227.151238] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=2
[  237.650232] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=2
[  237.671343] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=2
[  277.980310] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=9
[  278.001481] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=9
[  288.339220] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=9
[  288.361908] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=9
[  298.682988] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=9
[  298.704055] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=9
[  350.368952] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  350.389770] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  360.724821] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  360.746100] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  845.231887] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=27
[  845.233770] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  845.253196] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=27
[  845.254910] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[ 1397.628073] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=2
[ 1397.649165] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=2
[ 1408.207041] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=2
[ 1408.228762] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=2
----------

For the latter case, most of output showed that
ACTIVE_FILE + INACTIVE_FILE > 0.

----------
[  142.647201] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  142.648883] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  142.842868] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  142.955817] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  143.086363] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  143.231120] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  143.359238] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  143.473342] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  143.618103] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  143.746210] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  143.908162] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  144.035415] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  144.161926] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  144.306435] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  144.434265] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  144.436099] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  144.643374] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  144.773239] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  144.902309] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  145.046154] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  145.185410] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  145.317218] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  145.460304] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  145.654212] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  145.817362] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  145.945136] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  146.086303] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  146.242127] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  153.489868] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  153.491593] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  153.674246] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  153.839478] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  154.003234] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  154.155085] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  154.322187] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  154.447355] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  154.653150] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  154.782216] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  154.939439] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  155.105921] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  155.278386] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  155.440832] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  155.623970] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  155.625766] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  155.831074] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  155.996903] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  156.139137] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  156.318492] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  156.484300] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  156.667411] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  156.817246] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  157.012323] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  157.159483] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  157.323193] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  157.488399] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  157.654198] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  164.339172] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  164.340896] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  164.583026] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  164.797386] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  164.965110] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  165.124935] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  165.431304] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  165.700317] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  165.862071] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  166.029257] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  166.198312] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  166.356224] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  166.559302] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  166.684486] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  166.898551] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  166.900496] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  167.175960] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  167.324390] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  167.526150] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  167.693365] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  167.878407] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  168.061503] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  168.225306] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  168.416398] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  168.617395] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  168.783201] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  168.989053] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  169.196126] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  175.361136] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  175.362865] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  175.626817] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  175.797361] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  176.006389] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  176.211479] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  176.433890] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  176.630951] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  176.855509] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  177.049814] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  177.258218] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  177.455404] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  177.665085] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  177.874173] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  178.057217] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  178.059056] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  178.350935] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  178.559404] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  178.782483] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  178.982803] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  179.203930] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  179.428321] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  179.611349] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  179.851164] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  180.034220] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  180.279197] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  180.455284] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  180.811445] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  186.368405] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  186.370115] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  186.614733] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  186.845695] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  187.024274] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  187.211389] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  187.427147] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  187.552333] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  187.734117] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  187.935811] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  188.138296] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  188.354041] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  188.559245] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  188.641776] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  188.716434] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  188.718199] (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  189.015952] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  189.218976] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  189.440131] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  189.659238] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  189.882360] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  190.087342] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  190.314442] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  190.408926] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  190.631240] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  190.850326] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  191.067488] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  191.283243] (ACTIVE_FILE=16+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
----------

So, something is preventing ACTIVE_FILE and INACTIVE_FILE to become 0 ?

I also tried below change, but the result was same. Therefore, this
problem seems to be independent with "!__GFP_FS allocations do not fail".
(Complete log with below change (uptime > 101) is at
http://I-love.SAKURA.ne.jp/tmp/serial-20151013-2.txt.xz . )

----------
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2736,7 +2736,6 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 			 * and the OOM killer can't be invoked, but
 			 * keep looping as per tradition.
 			 */
-			*did_some_progress = 1;
 			goto out;
 		}
 		if (pm_suspended_storage())
----------

----------
[  102.719555] (ACTIVE_FILE=3+INACTIVE_FILE=3) * 6 > PAGES_SCANNED=19
[  102.721234] (ACTIVE_FILE=1+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  102.722908] shrink_zones returned 1 at line 2717
----------

> So the do_try_to_free_pages() logic that does that
> 
>         /* Any of the zones still reclaimable?  Don't OOM. */
>         if (zones_reclaimable)
>                 return 1;
> 
> is rather dubious. The history of that odd line is pretty dubious too:
> it used to be that we would return success if "shrink_zones()"
> succeeded or if "nr_reclaimed" was non-zero, but that "shrink_zones()"
> logic got rewritten, and I don't think the current situation is all
> that sane.
> 
> And returning 1 there is actively misleading to callers, since it
> makes them think that it made progress.
> 
> So I think you should look at what happens if you just remove that
> illogical and misleading return value.
> 

If I remove

	/* Any of the zones still reclaimable?  Don't OOM. */
	if (zones_reclaimable)
		return 1;

the OOM killer is invoked even when there are so much memory which can be
reclaimed after written to disk. This is definitely premature invocation of
the OOM killer.

  $ cat < /dev/zero > /tmp/log & sleep 10; ./a.out

---------- When there is a lot of data to write ----------
[  489.952827] Mem-Info:
[  489.953840] active_anon:328227 inactive_anon:3033 isolated_anon:26
[  489.953840]  active_file:2309 inactive_file:80915 isolated_file:0
[  489.953840]  unevictable:0 dirty:53 writeback:80874 unstable:0
[  489.953840]  slab_reclaimable:4975 slab_unreclaimable:4256
[  489.953840]  mapped:2973 shmem:4192 pagetables:1939 bounce:0
[  489.953840]  free:12963 free_pcp:60 free_cma:0
[  489.963395] Node 0 DMA free:7300kB min:400kB low:500kB high:600kB active_anon:5728kB inactive_anon:88kB active_file:140kB inactive_file:1276kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:1300kB mapped:140kB shmem:160kB slab_reclaimable:256kB slab_unreclaimable:180kB kernel_stack:64kB pagetables:180kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:9768 all_unreclaimable? yes
[  489.974035] lowmem_reserve[]: 0 1729 1729 1729
[  489.975813] Node 0 DMA32 free:44552kB min:44652kB low:55812kB high:66976kB active_anon:1307180kB inactive_anon:12044kB active_file:9096kB inactive_file:322384kB unevictable:0kB isolated(anon):104kB isolated(file):0kB present:2080640kB managed:1774264kB mlocked:0kB dirty:216kB writeback:322196kB mapped:11752kB shmem:16608kB slab_reclaimable:19644kB slab_unreclaimable:16844kB kernel_stack:3584kB pagetables:7576kB unstable:0kB bounce:0kB free_pcp:240kB local_pcp:120kB free_cma:0kB writeback_tmp:0kB pages_scanned:2419896 all_unreclaimable? yes
[  489.988452] lowmem_reserve[]: 0 0 0 0
[  489.990043] Node 0 DMA: 2*4kB (UE) 1*8kB (M) 4*16kB (UME) 1*32kB (E) 2*64kB (UE) 3*128kB (UME) 2*256kB (UM) 2*512kB (ME) 1*1024kB (E) 2*2048kB (ME) 0*4096kB = 7280kB
[  489.995142] Node 0 DMA32: 578*4kB (UME) 726*8kB (UE) 447*16kB (UE) 253*32kB (UME) 155*64kB (UME) 42*128kB (UME) 3*256kB (UME) 2*512kB (UM) 4*1024kB (U) 0*2048kB 0*4096kB = 44552kB
[  490.000511] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  490.002914] 87434 total pagecache pages
[  490.004612] 0 pages in swap cache
[  490.006138] Swap cache stats: add 0, delete 0, find 0/0
[  490.007976] Free swap  = 0kB
[  490.009329] Total swap = 0kB
[  490.011033] 524157 pages RAM
[  490.012352] 0 pages HighMem/MovableOnly
[  490.013903] 76615 pages reserved
[  490.015260] 0 pages hwpoisoned
---------- When there is a lot of data to write ----------

  $ ./a.out

---------- When there is no data to write ----------
[  792.359024] Mem-Info:
[  792.360001] active_anon:413751 inactive_anon:6226 isolated_anon:0
[  792.360001]  active_file:0 inactive_file:0 isolated_file:0
[  792.360001]  unevictable:0 dirty:0 writeback:0 unstable:0
[  792.360001]  slab_reclaimable:1243 slab_unreclaimable:3638
[  792.360001]  mapped:104 shmem:6236 pagetables:1033 bounce:0
[  792.360001]  free:12965 free_pcp:126 free_cma:0
[  792.368559] Node 0 DMA free:7292kB min:400kB low:500kB high:600kB active_anon:7040kB inactive_anon:160kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:160kB slab_reclaimable:24kB slab_unreclaimable:172kB kernel_stack:64kB pagetables:460kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:8 all_unreclaimable? yes
[  792.378240] lowmem_reserve[]: 0 1729 1729 1729
[  792.379834] Node 0 DMA32 free:44568kB min:44652kB low:55812kB high:66976kB active_anon:1647964kB inactive_anon:24744kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2080640kB managed:1774264kB mlocked:0kB dirty:0kB writeback:0kB mapped:416kB shmem:24784kB slab_reclaimable:4948kB slab_unreclaimable:14380kB kernel_stack:3104kB pagetables:3672kB unstable:0kB bounce:0kB free_pcp:504kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:8 all_unreclaimable? yes
[  792.390085] lowmem_reserve[]: 0 0 0 0
[  792.391643] Node 0 DMA: 3*4kB (UE) 0*8kB 3*16kB (UE) 24*32kB (ME) 11*64kB (UME) 5*128kB (UM) 2*256kB (ME) 3*512kB (ME) 1*1024kB (E) 1*2048kB (E) 0*4096kB = 7292kB
[  792.396201] Node 0 DMA32: 242*4kB (UME) 386*8kB (UME) 397*16kB (UME) 199*32kB (UE) 105*64kB (UME) 37*128kB (UME) 24*256kB (UME) 20*512kB (UME) 0*1024kB 0*2048kB 0*4096kB = 44616kB
[  792.401136] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  792.403356] 6250 total pagecache pages
[  792.404803] 0 pages in swap cache
[  792.406208] Swap cache stats: add 0, delete 0, find 0/0
[  792.407896] Free swap  = 0kB
[  792.409172] Total swap = 0kB
[  792.410460] 524157 pages RAM
[  792.411752] 0 pages HighMem/MovableOnly
[  792.413106] 76615 pages reserved
[  792.414493] 0 pages hwpoisoned
---------- When there is no data to write ----------

> HOWEVER.
> 
> I think that it's very true that we have then tuned all our *other*
> heuristics for taking this thing into account, so I suspect that we'll
> find that we'll need to tweak other places. But this crazy "let's say
> that we made progress even when we didn't" thing looks just wrong.
> 
> In particular, I think that you'll find that you will have to change
> the heuristics in __alloc_pages_slowpath() where we currently do
> 
>         if ((did_some_progress && order <= PAGE_ALLOC_COSTLY_ORDER) || ..
> 
> when the "did_some_progress" logic changes that radically.
> 

Yes. But we can't simply do

	if (order <= PAGE_ALLOC_COSTLY_ORDER || ..

because we won't be able to call out_of_memory(), can we?

> Because while the current return value looks insane, all the other
> testing and tweaking has been done with that very odd return value in
> place.
> 
>                 Linus
> 

Well, did I encounter a difficult to fix problem?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
