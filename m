Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id C5CF96B0005
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 10:54:03 -0500 (EST)
Received: by mail-io0-f169.google.com with SMTP id 1so143810485ion.1
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 07:54:03 -0800 (PST)
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com. [209.85.223.171])
        by mx.google.com with ESMTPS id a28si4508130ioj.94.2016.01.05.07.54.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 07:54:03 -0800 (PST)
Received: by mail-io0-f171.google.com with SMTP id 77so159702765ioc.2
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 07:54:03 -0800 (PST)
Date: Tue, 5 Jan 2016 16:54:01 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Unrecoverable Out Of Memory kernel error
Message-ID: <20160105155400.GC15594@dhcp22.suse.cz>
References: <1451408582.2783.20.camel@libero.it>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1451408582.2783.20.camel@libero.it>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guido Trentalancia <g.trentalancia@libero.it>
Cc: linux-mm@kvack.org

On Tue 29-12-15 18:03:02, Guido Trentalancia wrote:
> Hello.
> 
> I am getting an unrecoverable Out Of Memory error on kernel 4.3.1,
> while compiling Firefox 43.0.3. The system becomes unresponsive, the
> hard-disk is continuously busy and a hard-reboot must be forced.
> 
> Here is the report from the kernel:
[...]
> Dec 29 12:28:25 vortex kernel: Mem-Info:
> Dec 29 12:28:25 vortex kernel: active_anon:716916 inactive_anon:199483 isolated_anon:0
> Dec 29 12:28:25 vortex kernel: active_file:3108 inactive_file:3160 isolated_file:32
> Dec 29 12:28:25 vortex kernel: unevictable:4316 dirty:3173 writeback:55 unstable:0
> Dec 29 12:28:25 vortex kernel: slab_reclaimable:16548 slab_unreclaimable:9058
> Dec 29 12:28:25 vortex kernel: mapped:4037 shmem:13351 pagetables:6846 bounce:0
> Dec 29 12:28:25 vortex kernel: free:7058 free_pcp:295 free_cma:0
[...]
> Dec 29 12:28:25 vortex kernel: Free swap  = 0kB
> Dec 29 12:28:25 vortex kernel: Total swap = 16380kB

Your swap space is full and basically all the memory is eaten by the
anonymous memory which cannot be reclaimed.
[...]
> Dec 29 12:28:25 vortex kernel: Killed process 10197 (cc1plus) total-vm:969632kB, anon-rss:809184kB, file-rss:9308kB

This task is consuming a lot of memory so killing it should help to
release the memory pressure. It would be interesting to see whether the
task has died or not. Are there any follow up messages in the log?
Maybe the target task is stuck behind some lock which is blocked because
of a memory allocation. We have seen deadlocks like that in the past.
The current linux-next has some measures to reduce the probability of
such a deadlock so you might give it a try. Especially if this is
reproducible.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
