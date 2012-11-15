Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 700776B002B
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 03:55:35 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so1087554pbc.14
        for <linux-mm@kvack.org>; Thu, 15 Nov 2012 00:55:33 -0800 (PST)
Date: Thu, 15 Nov 2012 00:52:24 -0800
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: [RFC v3 0/3] vmpressure_fd: Linux VM pressure notifications
Message-ID: <20121115085224.GA4635@lizard>
References: <20121107105348.GA25549@lizard>
 <20121107112136.GA31715@shutemov.name>
 <CAOJsxLHY+3ZzGuGX=4o1pLfhRqjkKaEMyhX0ejB5nVrDvOWXNA@mail.gmail.com>
 <20121107114321.GA32265@shutemov.name>
 <alpine.DEB.2.00.1211141910050.14414@chino.kir.corp.google.com>
 <20121115033932.GA15546@lizard.sbx05977.paloaca.wayport.net>
 <alpine.DEB.2.00.1211141946370.14414@chino.kir.corp.google.com>
 <20121115073420.GA19036@lizard.sbx05977.paloaca.wayport.net>
 <alpine.DEB.2.00.1211142351420.4410@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1211142351420.4410@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org

On Thu, Nov 15, 2012 at 12:11:47AM -0800, David Rientjes wrote:
[...]
> Might not be too difficult if you implement your own cgroup to aggregate 
> these tasks for which you want to know memory pressure events; it would 
> have to be triggered for the task trying to allocate memory at any given 
> time and how hard it was to allocate that memory in the slowpath, tie it 
> back to that tasks' memory pressure cgroup, and then report the trigger if 
> it's over a user-defined threshold normalized to the 0-100 scale.  Then 
> you could co-mount this cgroup with memcg, cpusets, or just do it for the 
> root cgroup for users who want to monitor the entire system

This seems doable. But

> (CONFIG_CGROUPS is enabled by default).

Hehe, you're saying that we have to have cgroups=y. :) But some folks were
deliberately asking us to make the cgroups optional.

OK, here is what I can try to do:

- Implement memory pressure cgroup as you described, by doing so we'd make
  the thing play well with cpusets and memcg;

- This will be eventfd()-based;

- Once done, we will have a solution for pretty much every major use-case
  (i.e. servers, desktops and Android, they all have cgroups enabled);

(- Optionally, if there will be a demand, for CGROUPS=n we can implement a
separate sysfs file with the exactly same eventfd interface, it will only
report global pressure. This will be for folks that don't want the cgroups
for some reason. The interface can be discussed separately.)

Thanks,
Anton.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
