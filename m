Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 9553F6B005C
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 04:59:58 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id D0ACB3EE0AE
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 17:59:56 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B763045DEB5
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 17:59:56 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9393745DEB4
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 17:59:56 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 85CCE1DB803E
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 17:59:56 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2DB2E1DB8038
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 17:59:56 +0900 (JST)
Message-ID: <4FD70492.2090709@jp.fujitsu.com>
Date: Tue, 12 Jun 2012 17:57:54 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH -V8 16/16] hugetlb/cgroup: add HugeTLB controller documentation
References: <1339232401-14392-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1339232401-14392-17-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1339232401-14392-17-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, dhillf@gmail.com, rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

(2012/06/09 18:00), Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V"<aneesh.kumar@linux.vnet.ibm.com>
> 
> Signed-off-by: Aneesh Kumar K.V<aneesh.kumar@linux.vnet.ibm.com>

Documentation in patch 1/16 will help other guy's review.


> ---
>   Documentation/cgroups/hugetlb.txt |   45 +++++++++++++++++++++++++++++++++++++
>   1 file changed, 45 insertions(+)
>   create mode 100644 Documentation/cgroups/hugetlb.txt
> 
> diff --git a/Documentation/cgroups/hugetlb.txt b/Documentation/cgroups/hugetlb.txt
> new file mode 100644
> index 0000000..a9faaca
> --- /dev/null
> +++ b/Documentation/cgroups/hugetlb.txt
> @@ -0,0 +1,45 @@
> +HugeTLB Controller
> +-------------------
> +
> +The HugeTLB controller allows to limit the HugeTLB usage per control group and
> +enforces the controller limit during page fault. Since HugeTLB doesn't
> +support page reclaim, enforcing the limit at page fault time implies that,
> +the application will get SIGBUS signal if it tries to access HugeTLB pages
> +beyond its limit. This requires the application to know beforehand how much
> +HugeTLB pages it would require for its use.
> +


Isn't it better to mention hugetlb cgroup doesn't have its own free-huge-page-list,
it's just a quota. And system admin need to set up hugetlb page pool regardless
of using hugetlb cgroup.


> +HugeTLB controller can be created by first mounting the cgroup filesystem.
> +
> +# mount -t cgroup -o hugetlb none /sys/fs/cgroup
> +
> +With the above step, the initial or the parent HugeTLB group becomes
> +visible at /sys/fs/cgroup. At bootup, this group includes all the tasks in
> +the system. /sys/fs/cgroup/tasks lists the tasks in this cgroup.
> +
> +New groups can be created under the parent group /sys/fs/cgroup.
> +
> +# cd /sys/fs/cgroup
> +# mkdir g1
> +# echo $$>  g1/tasks
> +
> +The above steps create a new group g1 and move the current shell
> +process (bash) into it.
> +
> +Brief summary of control files
> +
> + hugetlb.<hugepagesize>.limit_in_bytes     # set/show limit of "hugepagesize" hugetlb usage
> + hugetlb.<hugepagesize>.max_usage_in_bytes # show max "hugepagesize" hugetlb  usage recorded
> + hugetlb.<hugepagesize>.usage_in_bytes     # show current res_counter usage for "hugepagesize" hugetlb
> + hugetlb.<hugepagesize>.failcnt		   # show the number of allocation failure due to HugeTLB limit
                                         ^^^^^^^^
breakage in spacing.

> +
> +For a system supporting two hugepage size (16M and 16G) the control
> +files include:
> +
> +hugetlb.16GB.limit_in_bytes
> +hugetlb.16GB.max_usage_in_bytes
> +hugetlb.16GB.usage_in_bytes
> +hugetlb.16GB.failcnt
> +hugetlb.16MB.limit_in_bytes
> +hugetlb.16MB.max_usage_in_bytes
> +hugetlb.16MB.usage_in_bytes
> +hugetlb.16MB.failcnt

seems nice.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
