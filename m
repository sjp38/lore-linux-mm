Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 97AEE6B03A1
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 01:41:42 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id a140so5424355ita.3
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 22:41:42 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id b137si1720592itc.9.2017.04.18.22.41.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 18 Apr 2017 22:41:41 -0700 (PDT)
Message-Id: <201704190541.v3J5fUE3054131@www262.sakura.ne.jp>
Subject: Re: Re: "mm: move pcp and lru-pcp draining into single wq" broke resume
 from s2ram
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Wed, 19 Apr 2017 14:41:30 +0900
References: <CAMuHMdUJSfrZ=2zy88_zojDek3CHEWKhv_qoJAVgDpPWz8V=Ew@mail.gmail.com> <20170418201907.GC20671@dhcp22.suse.cz>
In-Reply-To: <20170418201907.GC20671@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux PM list <linux-pm@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Linux-Renesas <linux-renesas-soc@vger.kernel.org>, Tejun Heo <tj@kernel.org>

Geert Uytterhoeven wrote:
> 8 locks held by s2ram/1899:
>  #0:  (sb_writers#7){.+.+.+}, at: [<ffffff80081ca1a4>] vfs_write+0xa8/0x15c
>  #1:  (&of->mutex){+.+.+.}, at: [<ffffff8008245964>] kernfs_fop_write+0xf0/0x194
>  #2:  (s_active#48){.+.+.+}, at: [<ffffff800824596c>] kernfs_fop_write+0xf8/0x194
>  #3:  (pm_mutex){+.+.+.}, at: [<ffffff80081059a4>] pm_suspend+0x16c/0xabc
>  #4:  (&dev->mutex){......}, at: [<ffffff80083d4920>] device_resume+0x58/0x190
>  #5:  (cma_mutex){+.+...}, at: [<ffffff80081c516c>] cma_alloc+0x150/0x374
>  #6:  (lock){+.+...}, at: [<ffffff800818b8ec>] lru_add_drain_all+0x4c/0x1b4
>  #7:  (cpu_hotplug.dep_map){++++++}, at: [<ffffff80080ab8f4>] get_online_cpus+0x3c/0x9c

I think this situation suggests that

int pm_suspend(suspend_state_t state) {
  error = enter_state(state) {
    if (!mutex_trylock(&pm_mutex)) /* #3 */
      return -EBUSY;
    error = suspend_devices_and_enter(state) {
      error = suspend_enter(state, &wakeup) {
        enable_nonboot_cpus() {
          cpu_maps_update_begin() {
            mutex_lock(&cpu_add_remove_lock);
          }
          pr_info("Enabling non-boot CPUs ...\n");
          for_each_cpu(cpu, frozen_cpus) {
            error = _cpu_up(cpu, 1, CPUHP_ONLINE) {
              cpu_hotplug_begin() {
                mutex_lock(&cpu_hotplug.lock);
              }
              
              cpu_hotplug_done() {
                mutex_unlock(&cpu_hotplug.lock);
              }
            }
            if (!error) {
              pr_info("CPU%d is up\n", cpu);
              continue;
            }
          }
          cpu_maps_update_done() {
             mutex_unlock(&cpu_add_remove_lock);
          }
        }
      }
      dpm_resume_end(PMSG_RESUME) {
        dpm_resume(state) {
          mutex_lock(&dpm_list_mtx);
          while (!list_empty(&dpm_suspended_list)) {
            mutex_unlock(&dpm_list_mtx);
            error = device_resume(dev, state, false) {
              dpm_wait_for_superior(dev, async);
              dpm_watchdog_set(&wd, dev);
              device_lock(dev) {
                mutex_lock(&dev->mutex); /* #4 */
              }
              error = dpm_run_callback(callback, dev, state, info) {
                cma_alloc() {
                  mutex_lock(&cma_mutex); /* #5 */
                  alloc_contig_range() {
                    lru_add_drain_all() {
                      mutex_lock(&lock); /* #6 */
                      get_online_cpus() {
                        mutex_lock(&cpu_hotplug.lock); /* #7 hang? */
                        mutex_unlock(&cpu_hotplug.lock);
                      }
                      put_online_cpus();
                      mutex_unlock(&lock); /* #6 */
                    }
                  }
                  mutex_unlock(&cma_mutex); /* #5 */
                }
              }
              device_unlock(dev) {
                mutex_unlock(&dev->mutex); /* #4 */
              }
            }
            mutex_lock(&dpm_list_mtx);
          }
          mutex_unlock(&dpm_list_mtx);
        }
        dpm_complete(state) {
          mutex_lock(&dpm_list_mtx);
          while (!list_empty(&dpm_prepared_list)) {
            mutex_unlock(&dpm_list_mtx);
            device_complete(dev, state) {
            }
            mutex_lock(&dpm_list_mtx);
          }
          mutex_unlock(&dpm_list_mtx);
        }
      }
    }
    mutex_unlock(&pm_mutex); /* #3 */
  }
}

Somebody is waiting forever with cpu_hotplug.lock held?
I think that full dmesg with SysRq-t output is appreciated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
