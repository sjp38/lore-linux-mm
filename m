Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF50DC282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 07:02:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6124F20869
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 07:02:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6124F20869
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C77068E0002; Fri,  1 Feb 2019 02:02:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C27468E0001; Fri,  1 Feb 2019 02:02:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AED098E0002; Fri,  1 Feb 2019 02:02:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 530238E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 02:02:31 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id v4so2349708edm.18
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 23:02:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=RV8g06Fmuy641F5jNvf3hcLdM57CZcldX6LIbaE2rQU=;
        b=Nyv6VzUsWRje2o3qj1OXaLfFWeHOMmXZD55XZPcWjDfNofVJ2dRutIdKsWOQwY3Hbk
         m6z10pke6Lu3OKL40BkaijIuY2+ok5mMm8acvuJtvmkEBaCN3rzaQ9uFpHHuxz7aQhSy
         jq5ZL9JHMmmw4JEpsfOVvFbuOQMXtEFdtiiLb8N556BwIvahIz4DQRzy0w0Icq1C8YIy
         059QpViekZb36iD1pFbcZAgtbrzOC+G4mJzHx8sTjRRjbhs/yoRenZ4S0pUKaRp4YWxy
         XMbQCb+JhNmojAUmqXQSv6byouXz6Tx2VYANphr8xcsd/D1Shdawgc0B/0aqqrio/PKW
         nCcA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: AHQUAub76sHAURJZkkiktapamx5EfEUkScGgIcD9ndFX2Lkap6tHbEft
	eiMhsTkvC1PMaveoCQ1HsiSHzT+q1sLWgvl8OMpRiuqI4FLJWNk3St66drhe8oEpu8pl2amQ3qO
	ewwvNKIMl1O/s4XNirfWqKKKjvw+l1hI+IXfjj7uJoHF/u+8gg7180dJLPK05wCWVdA==
X-Received: by 2002:a17:906:e0d6:: with SMTP id gl22mr13374943ejb.239.1549004550710;
        Thu, 31 Jan 2019 23:02:30 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaYOSgCSa2Gx8nX9gCg0IW4BAG/V8bxJSZ3/KGkfjx4FPIuh7Gw4dmgVcbXOUuNdMpOZgD5
X-Received: by 2002:a17:906:e0d6:: with SMTP id gl22mr13374854ejb.239.1549004549142;
        Thu, 31 Jan 2019 23:02:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549004549; cv=none;
        d=google.com; s=arc-20160816;
        b=VKXHEbdVxj9q52LJMsohuFjyw5ZZshemGn78RmM+3CKxnvXIqZ/gdSanypzeBEBf6u
         9aZRow1bgnVpxye4hH5mmd5CW5yuwD2XzE7/xThHdClvnmI+s87d8+abRkxEgyKcpwMU
         4UNPPVI4paI0FFC3XfipmiuqAwNm5eu3oVvwBsCociXIQ7QMhqLkfVTVtTFElca12lIk
         Q0Uo1vGo6bUVpGfUmOD/AtImjvKikWK95hulUIgmX7grWTj42YEwu+PK940yhMTfSTgF
         q5WCoJV3iij2R5BtoqJrrvvtV0iw1M4Q6ezDyYeauNUsH08zS9UGdDQ4jYm9f4C4gJnT
         UkkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=RV8g06Fmuy641F5jNvf3hcLdM57CZcldX6LIbaE2rQU=;
        b=CHZdsQ7DqF3X/nKrptlJeTQLurIPo/Qewx2V1c2paZtvCteRqx56SKL0Ync2xJKzNx
         adsEpaxKNH1qeDttxQPp0BH+LFB+UZywkmsW+4ls1O+/D6cwckWdyp13hu81bgdVnbtI
         CR58ydEDBc/Ie7xUl6Ut3vwNT4sycFc1hr0OKeL/cDGZ9azcmPWHeLKJUFdCNvj7fuRo
         C1X01WKKstZtAWayqVkx+maRGHNtQYtpcNrlQHcVLDqOS6CA6vA4bB8FQVsuJ/Oip2Lc
         ckx65CzwxOTdYWBrYZVLKN9m4hW1Bigcz8qeGjo9qnJc9jRzUP9BwakKtakmkfE2y4AG
         1dXw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t20-v6si1178690ejf.57.2019.01.31.23.02.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 23:02:29 -0800 (PST)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 068EEADE2;
	Fri,  1 Feb 2019 07:02:27 +0000 (UTC)
Date: Fri, 1 Feb 2019 08:02:26 +0100
From: Michal Hocko <mhocko@suse.com>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>,
	Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org
Subject: Re: [PATCH] mm,oom: Don't kill global init via memory.oom.group
Message-ID: <20190201070226.GC11599@dhcp22.suse.cz>
References: <201902010336.x113a4EO027170@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201902010336.x113a4EO027170@www262.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 01-02-19 12:36:04, Tetsuo Handa wrote:
> ----------
> #include <stdio.h>
> #include <string.h>
> #include <unistd.h>
> #include <sys/types.h>
> #include <sys/stat.h>
> #include <fcntl.h>
> 
> int main(int argc, char *argv[])
> {
> 	static char buffer[10485760];
> 	static int pipe_fd[2] = { EOF, EOF };
> 	unsigned int i;
> 	int fd;
> 	char buf[64] = { };
> 	if (pipe(pipe_fd))
> 		return 1;
> 	if (chdir("/sys/fs/cgroup/"))
> 		return 1;
> 	fd = open("cgroup.subtree_control", O_WRONLY);
> 	write(fd, "+memory", 7);
> 	close(fd);
> 	mkdir("test1", 0755);
> 	fd = open("test1/memory.oom.group", O_WRONLY);
> 	write(fd, "1", 1);
> 	close(fd);
> 	fd = open("test1/cgroup.procs", O_WRONLY);
> 	write(fd, "1", 1);
> 	snprintf(buf, sizeof(buf) - 1, "%d", getpid());
> 	write(fd, buf, strlen(buf));
> 	close(fd);
> 	snprintf(buf, sizeof(buf) - 1, "%lu", sizeof(buffer) * 5);
> 	fd = open("test1/memory.max", O_WRONLY);
> 	write(fd, buf, strlen(buf));
> 	close(fd);
> 	for (i = 0; i < 10; i++)
> 		if (fork() == 0) {
> 			char c;
> 			close(pipe_fd[1]);
> 			read(pipe_fd[0], &c, 1);
> 			memset(buffer, 0, sizeof(buffer));
> 			sleep(3);
> 			_exit(0);
> 		}
> 	close(pipe_fd[0]);
> 	close(pipe_fd[1]);
> 	sleep(3);
> 	return 0;
> }
> ----------
> 
> ----------
> [   37.052923][ T9185] a.out invoked oom-killer: gfp_mask=0xcc0(GFP_KERNEL), order=0, oom_score_adj=0
> [   37.056169][ T9185] CPU: 4 PID: 9185 Comm: a.out Kdump: loaded Not tainted 5.0.0-rc4-next-20190131 #280
> [   37.059205][ T9185] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 04/13/2018
> [   37.062954][ T9185] Call Trace:
> [   37.063976][ T9185]  dump_stack+0x67/0x95
> [   37.065263][ T9185]  dump_header+0x51/0x570
> [   37.066619][ T9185]  ? trace_hardirqs_on+0x3f/0x110
> [   37.068171][ T9185]  ? _raw_spin_unlock_irqrestore+0x3d/0x70
> [   37.069967][ T9185]  oom_kill_process+0x18d/0x210
> [   37.071515][ T9185]  out_of_memory+0x11b/0x380
> [   37.072936][ T9185]  mem_cgroup_out_of_memory+0xb6/0xd0
> [   37.074601][ T9185]  try_charge+0x790/0x820
> [   37.076021][ T9185]  mem_cgroup_try_charge+0x42/0x1d0
> [   37.077629][ T9185]  mem_cgroup_try_charge_delay+0x11/0x30
> [   37.079370][ T9185]  do_anonymous_page+0x105/0x5e0
> [   37.080939][ T9185]  __handle_mm_fault+0x9cb/0x1070
> [   37.082485][ T9185]  handle_mm_fault+0x1b2/0x3a0
> [   37.083819][ T9185]  ? handle_mm_fault+0x47/0x3a0
> [   37.085181][ T9185]  __do_page_fault+0x255/0x4c0
> [   37.086529][ T9185]  do_page_fault+0x28/0x260
> [   37.087788][ T9185]  ? page_fault+0x8/0x30
> [   37.088978][ T9185]  page_fault+0x1e/0x30
> [   37.090142][ T9185] RIP: 0033:0x7f8b183aefe0
> [   37.091433][ T9185] Code: 20 f3 44 0f 7f 44 17 d0 f3 44 0f 7f 47 30 f3 44 0f 7f 44 17 c0 48 01 fa 48 83 e2 c0 48 39 d1 74 a3 66 0f 1f 84 00 00 00 00 00 <66> 44 0f 7f 01 66 44 0f 7f 41 10 66 44 0f 7f 41 20 66 44 0f 7f 41
> [   37.096917][ T9185] RSP: 002b:00007fffc5d329e8 EFLAGS: 00010206
> [   37.098615][ T9185] RAX: 00000000006010e0 RBX: 0000000000000008 RCX: 0000000000c30000
> [   37.100905][ T9185] RDX: 00000000010010c0 RSI: 0000000000000000 RDI: 00000000006010e0
> [   37.103349][ T9185] RBP: 0000000000000000 R08: 00007f8b188f4740 R09: 0000000000000000
> [   37.105797][ T9185] R10: 00007fffc5d32420 R11: 00007f8b183aef40 R12: 0000000000000005
> [   37.108228][ T9185] R13: 0000000000000000 R14: ffffffffffffffff R15: 0000000000000000
> [   37.110840][ T9185] memory: usage 51200kB, limit 51200kB, failcnt 125
> [   37.113045][ T9185] memory+swap: usage 0kB, limit 9007199254740988kB, failcnt 0
> [   37.115808][ T9185] kmem: usage 0kB, limit 9007199254740988kB, failcnt 0
> [   37.117660][ T9185] Memory cgroup stats for /test1: cache:0KB rss:49484KB rss_huge:30720KB shmem:0KB mapped_file:0KB dirty:0KB writeback:0KB inactive_anon:0KB active_anon:49700KB inactive_file:0KB active_file:0KB unevictable:0KB
> [   37.123371][ T9185] oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null),cpuset=/,mems_allowed=0,oom_memcg=/test1,task_memcg=/test1,task=a.out,pid=9188,uid=0
> [   37.128158][ T9185] Memory cgroup out of memory: Killed process 9188 (a.out) total-vm:14456kB, anon-rss:10324kB, file-rss:504kB, shmem-rss:0kB
> [   37.132710][ T9185] Tasks in /test1 are going to be killed due to memory.oom.group set
> [   37.132833][   T54] oom_reaper: reaped process 9188 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> [   37.135498][ T9185] Memory cgroup out of memory: Killed process 1 (systemd) total-vm:43400kB, anon-rss:1228kB, file-rss:3992kB, shmem-rss:0kB
> [   37.143434][ T9185] Memory cgroup out of memory: Killed process 9182 (a.out) total-vm:14456kB, anon-rss:76kB, file-rss:588kB, shmem-rss:0kB
> [   37.144328][   T54] oom_reaper: reaped process 1 (systemd), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> [   37.147585][ T9185] Memory cgroup out of memory: Killed process 9183 (a.out) total-vm:14456kB, anon-rss:6228kB, file-rss:512kB, shmem-rss:0kB
> [   37.157222][ T9185] Memory cgroup out of memory: Killed process 9184 (a.out) total-vm:14456kB, anon-rss:6228kB, file-rss:508kB, shmem-rss:0kB
> [   37.157259][ T9185] Memory cgroup out of memory: Killed process 9185 (a.out) total-vm:14456kB, anon-rss:6228kB, file-rss:512kB, shmem-rss:0kB
> [   37.157291][ T9185] Memory cgroup out of memory: Killed process 9186 (a.out) total-vm:14456kB, anon-rss:4180kB, file-rss:508kB, shmem-rss:0kB
> [   37.157306][   T54] oom_reaper: reaped process 9183 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> [   37.157328][ T9185] Memory cgroup out of memory: Killed process 9187 (a.out) total-vm:14456kB, anon-rss:4180kB, file-rss:512kB, shmem-rss:0kB
> [   37.157452][ T9185] Memory cgroup out of memory: Killed process 9189 (a.out) total-vm:14456kB, anon-rss:6228kB, file-rss:512kB, shmem-rss:0kB
> [   37.158733][ T9185] Memory cgroup out of memory: Killed process 9190 (a.out) total-vm:14456kB, anon-rss:552kB, file-rss:512kB, shmem-rss:0kB
> [   37.160083][   T54] oom_reaper: reaped process 9186 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> [   37.160187][   T54] oom_reaper: reaped process 9189 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> [   37.206941][   T54] oom_reaper: reaped process 9185 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> [   37.212300][ T9185] Memory cgroup out of memory: Killed process 9191 (a.out) total-vm:14456kB, anon-rss:4180kB, file-rss:512kB, shmem-rss:0kB
> [   37.212317][   T54] oom_reaper: reaped process 9190 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> [   37.218860][ T9185] Memory cgroup out of memory: Killed process 9192 (a.out) total-vm:14456kB, anon-rss:1080kB, file-rss:512kB, shmem-rss:0kB
> [   37.227667][   T54] oom_reaper: reaped process 9192 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> [   37.292323][ T9193] abrt-hook-ccpp (9193) used greatest stack depth: 10480 bytes left
> [   37.351843][    T1] Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000008b
> [   37.354833][    T1] CPU: 7 PID: 1 Comm: systemd Kdump: loaded Not tainted 5.0.0-rc4-next-20190131 #280
> [   37.357876][    T1] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 04/13/2018
> [   37.361685][    T1] Call Trace:
> [   37.363239][    T1]  dump_stack+0x67/0x95
> [   37.365010][    T1]  panic+0xfc/0x2b0
> [   37.366853][    T1]  do_exit+0xd55/0xd60
> [   37.368595][    T1]  do_group_exit+0x47/0xc0
> [   37.370415][    T1]  get_signal+0x32a/0x920
> [   37.372449][    T1]  ? _raw_spin_unlock_irqrestore+0x3d/0x70
> [   37.374596][    T1]  do_signal+0x32/0x6e0
> [   37.376430][    T1]  ? exit_to_usermode_loop+0x26/0x9b
> [   37.378418][    T1]  ? prepare_exit_to_usermode+0xa8/0xd0
> [   37.380571][    T1]  exit_to_usermode_loop+0x3e/0x9b
> [   37.382588][    T1]  prepare_exit_to_usermode+0xa8/0xd0
> [   37.384594][    T1]  ? page_fault+0x8/0x30
> [   37.386453][    T1]  retint_user+0x8/0x18
> [   37.388160][    T1] RIP: 0033:0x7f42c06974a8
> [   37.389922][    T1] Code: Bad RIP value.
> [   37.391788][    T1] RSP: 002b:00007ffc3effd388 EFLAGS: 00010213
> [   37.394075][    T1] RAX: 000000000000000e RBX: 00007ffc3effd390 RCX: 0000000000000000
> [   37.396963][    T1] RDX: 000000000000002a RSI: 00007ffc3effd390 RDI: 0000000000000004
> [   37.399550][    T1] RBP: 00007ffc3effd680 R08: 0000000000000000 R09: 0000000000000000
> [   37.402334][    T1] R10: 00000000ffffffff R11: 0000000000000246 R12: 0000000000000001
> [   37.404890][    T1] R13: ffffffffffffffff R14: 0000000000000884 R15: 000056460b1ac3b0
> ----------
> 
> >From 83108ee95816800840ccc68c3a52fb000b572370 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Fri, 1 Feb 2019 11:41:38 +0900
> Subject: [PATCH] mm,oom: Don't kill global init via memory.oom.group
> 
> Since setting global init process to some memory cgroup is
> technically possible, oom_kill_memcg_member() must check it.
> 
>   Tasks in /test1 are going to be killed due to memory.oom.group set
>   Memory cgroup out of memory: Killed process 1 (systemd) total-vm:43400kB, anon-rss:1228kB, file-rss:3992kB, shmem-rss:0kB
>   oom_reaper: reaped process 1 (systemd), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
>   Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000008b
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Fixes: 3d8b38eb81cac813 ("mm, oom: introduce memory.oom.group")
> Cc: Roman Gushchin <guro@fb.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!
> ---
>  mm/oom_kill.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index f0e8cd9..f8603c0 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -928,7 +928,8 @@ static void __oom_kill_process(struct task_struct *victim)
>   */
>  static int oom_kill_memcg_member(struct task_struct *task, void *unused)
>  {
> -	if (task->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
> +	if (task->signal->oom_score_adj != OOM_SCORE_ADJ_MIN &&
> +	    !is_global_init(task)) {
>  		get_task_struct(task);
>  		__oom_kill_process(task);
>  	}
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

