Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id CA89C6B0253
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 12:09:48 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k15so4635275wrc.1
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 09:09:48 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 13sor2042294ljb.93.2017.10.03.09.09.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Oct 2017 09:09:47 -0700 (PDT)
Date: Tue, 3 Oct 2017 19:09:44 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: crash during new kmem-limited memory cgroup creation if
 kmem_cache has been created when previous memory cgroup were inactive
Message-ID: <20171003160944.ojiek7wtu3cmyow6@esperanza>
References: <0537E873-CE22-4E6D-912A-6C8FDCF85493@intel.com>
 <20171002143244.lrp5nd2rf3lmjsql@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20171002143244.lrp5nd2rf3lmjsql@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Faccini, Bruno" <bruno.faccini@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, linux-mm@kvack.org

Hello Bruno,

On Mon, Oct 02, 2017 at 04:32:44PM +0200, Michal Hocko wrote:
> [CC Vldimir and linux-mm]
> 
> On Tue 19-09-17 22:42:37, Faccini, Bruno wrote:
> > The panic threada??s stack looks like :
> > ============================
> > [38212.118675] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
> > [38212.120795] IP: [<ffffffff811dbb04>] __memcg_kmem_get_cache+0xe4/0x220

Kernel memory accounting is totally unusable in 3.10, because it lacks
dcache reclaim and there are a lot of implementation bugs. The one you
caught is just one of many that have been fixed since 3.10. That's why
it stayed disabled by default until 4.x.

So IMHO the best you can do if you really want to use kernel memory
accounting is upgrade to 4.x or backport all related patches.

> > and we can easily trigger it when running one of our regression test
> > that is intended to test our software robustness against lack of
> > Kernel memory, by setting very restrictive kmem limit for a memory
> > cgroup where testa??s tasks/contexts will be attached during their
> > execution.

Lack of kernel memory typically results in OOM and killing your
software. The fact that it isn't like that in kmemcg-3.10 and you can
easily get ENOMEM, for example, while scanning a directory is actually
a bug, which was fixed in 4.x.

AFAIU you want to test ENOMEM handling paths. Then IMHO you'd better use
some kind of error injection either in userspace or in kernel, e.g. you
might want to take a look at CONFIG_FAILSLAB.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
