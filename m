Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id AF19C28093C
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 20:47:18 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id o24so145038007otb.7
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 17:47:18 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id r23si1988798otb.232.2017.03.10.17.47.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Mar 2017 17:47:17 -0800 (PST)
Subject: Re: [PATCH v7] mm: Add memory allocation watchdog kernel thread.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201703091946.GDC21885.OQFFOtJHSOFVML@I-love.SAKURA.ne.jp>
	<20170309143751.05bddcbad82672384947de5f@linux-foundation.org>
	<20170310104047.GF3753@dhcp22.suse.cz>
	<201703102019.JHJ58283.MQHtVFOOFOLFJS@I-love.SAKURA.ne.jp>
	<20170310152611.GM3753@dhcp22.suse.cz>
In-Reply-To: <20170310152611.GM3753@dhcp22.suse.cz>
Message-Id: <201703111046.FBB87020.OVOOQFMHFSJLtF@I-love.SAKURA.ne.jp>
Date: Sat, 11 Mar 2017 10:46:58 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, mgorman@techsingularity.net, david@fromorbit.com, apolyakov@beget.ru

Michal Hocko wrote:
> So, we have means to debug these issues. Some of them are rather coarse
> and your watchdog can collect much more and maybe give us a clue much
> quicker but we still have to judge whether all this is really needed
> because it doesn't come for free. Have you considered this aspect?

Sigh... You are ultimately ignoring the reality. Educating everybody to master
debugging tools does not come for free. If I liken your argumentation to
security modules, it looks like the following.

  "There is already SELinux. SELinux can do everything. Thus, AppArmor is not needed.
   I don't care about users/customers who cannot administrate SELinux."

The reality is different. We need tools which users/customers can afford using.
You had better getting away from existing debug tools which kernel developers
are using.

First of all, SysRq is an emergency tool and therefore it requires administrator's
intervention. Your argumentation sounds to me that "Give up debugging unless you
can sit on in front of console of Linux systems 24-7" which is already impossible.

SysRq-t cannot print seq= and delay= fields because information of in-flight allocation
request is not accessible from "struct task_struct", making extremely difficult to
judge whether progress is made when several SysRq-t snapshots are taken.

Also, year by year it is getting difficult to use vmcore for analysis because vmcore
might include sensitive data (even after filtering out user pages). I saw cases where
vmcore cannot be sent to support centers due to e.g. organization's information
control rules. Sometimes we have to analyze from only kernel messages. Some pieces of
information extracted by running scripts against /usr/bin/crash on cutomer's side
might be available, but in general we can't assume that the whole memory image which
includes whatever information is available.

In most cases, administrators can't capture even SysRq-t; let alone vmcore.
Therefore, automatic watchdog is highly appreciated. Have you considered this aspect?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
