From: Konstantin Khlebnikov <khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org>
Subject: [rfc] Binding files to data-only memory cgroups
Date: Fri, 28 Aug 2015 17:25:55 +0300
Message-ID: <55E06F73.2070808@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: linux-mm.kvack.org

Seems like subj could provide a very flexible approach for managing
memory in complicated scenarios. Depending on memory limits it could
work as mlock (with lock-on-fault semantics). Binding files to cgroup
with small memory limit gives long-awaited FADV_NOREUSE semantics.
Even without limits this gives valuable information about memory usage
by page-cache for particular set of files.

For example, our database keeps data in several files with completely
different access patterns: some of them should be cached and locked in
memory (but not completely), some shouldn't be cached because cache-hit
is almost impossible and so on. fadvise and mlock provides some
tuning but they are very limited.

Interface could be done as a single fadvise(fd, FADV_WILLOWN) which
binds inode to current memory cgroup (fails if already binded) and
migrates all present cache. All further allocations in this inode
will be charged to that cgroup. In userspace this will be used by
tiny tool which lives in target cgroup and holds all binded files,
so state will be persistent but without keeping anything in fs.

So, what do you think?
Is there any plans to alter always-charge-to-current logic?
