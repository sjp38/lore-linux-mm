Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4D6656B0038
	for <linux-mm@kvack.org>; Sat, 17 Dec 2016 09:45:07 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id c4so164498176pfb.7
        for <linux-mm@kvack.org>; Sat, 17 Dec 2016 06:45:07 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id s5si8347995pgo.49.2016.12.17.06.45.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 17 Dec 2016 06:45:05 -0800 (PST)
Subject: Re: OOM: Better, but still there on
References: <20161216073941.GA26976@dhcp22.suse.cz>
 <20161216155808.12809-1-mhocko@kernel.org>
 <20161216184655.GA5664@boerne.fritz.box>
 <20161217000203.GC23392@dhcp22.suse.cz>
 <20161217125950.GA3321@boerne.fritz.box>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <862a1ada-17f1-9cff-c89b-46c47432e89f@I-love.SAKURA.ne.jp>
Date: Sat, 17 Dec 2016 23:44:45 +0900
MIME-Version: 1.0
In-Reply-To: <20161217125950.GA3321@boerne.fritz.box>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nils Holland <nholland@tisys.org>, Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org

On 2016/12/17 21:59, Nils Holland wrote:
> On Sat, Dec 17, 2016 at 01:02:03AM +0100, Michal Hocko wrote:
>> mount -t tracefs none /debug/trace
>> echo 1 > /debug/trace/events/vmscan/enable
>> cat /debug/trace/trace_pipe > trace.log
>>
>> should help
>> [...]
> 
> No problem! I enabled writing the trace data to a file and then tried
> to trigger another OOM situation. That worked, this time without a
> complete kernel panic, but with only my processes being killed and the
> system becoming unresponsive. When that happened, I let it run for
> another minute or two so that in case it was still logging something
> to the trace file, it could continue to do so some time longer. Then I
> rebooted with the only thing that still worked, i.e. by means of magic
> SysRequest.

Under OOM situation, writing to a file on disk unlikely works. Maybe
logging via network ( "cat /debug/trace/trace_pipe > /dev/udp/$ip/$port"
if your are using bash) works better. (I wish we can do it from kernel
so that /bin/cat is not disturbed by delays due to page fault.)

If you can configure netconsole for logging OOM killer messages and
UDP socket for logging trace_pipe messages, udplogger at
https://osdn.net/projects/akari/scm/svn/tree/head/branches/udplogger/
might fit for logging both output with timestamp into a single file.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
