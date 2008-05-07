Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id m4758ANs001665
	for <linux-mm@kvack.org>; Wed, 7 May 2008 06:08:10 +0100
Received: from an-out-0708.google.com (anac36.prod.google.com [10.100.54.36])
	by zps38.corp.google.com with ESMTP id m47589Gs009872
	for <linux-mm@kvack.org>; Tue, 6 May 2008 22:08:09 -0700
Received: by an-out-0708.google.com with SMTP id c36so32122ana.22
        for <linux-mm@kvack.org>; Tue, 06 May 2008 22:08:09 -0700 (PDT)
Message-ID: <6599ad830805062208if98157cwaca4bafa01b8d097@mail.gmail.com>
Date: Tue, 6 May 2008 22:08:08 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH] mm/cgroup.c add error check
In-Reply-To: <20080506195216.4A6D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080506195216.4A6D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, May 6, 2008 at 4:02 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>
>  on heavy workload, call_usermodehelper() may failure
>  because it use kzmalloc(GFP_ATOMIC).
>
>  but userland want receive release notificcation even heavy workload.
>
>  thus, We should retry if -ENOMEM happend.
>
>
>  Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>  CC: "Paul Menage" <menage@google.com>
>  CC: Li Zefan <lizf@cn.fujitsu.com>
>
>  ---
>   kernel/cgroup.c |   10 +++++++++-
>   1 file changed, 9 insertions(+), 1 deletion(-)
>
>  Index: b/kernel/cgroup.c
>  ===================================================================
>  --- a/kernel/cgroup.c   2008-04-29 18:00:53.000000000 +0900
>  +++ b/kernel/cgroup.c   2008-05-06 20:28:23.000000000 +0900
>  @@ -3072,6 +3072,8 @@ void __css_put(struct cgroup_subsys_stat
>   */
>   static void cgroup_release_agent(struct work_struct *work)
>   {
>  +       int err;
>  +
>         BUG_ON(work != &release_agent_work);
>         mutex_lock(&cgroup_mutex);
>         spin_lock(&release_list_lock);
>  @@ -3111,7 +3113,13 @@ static void cgroup_release_agent(struct
>                  * since the exec could involve hitting disk and hence
>                  * be a slow process */
>                 mutex_unlock(&cgroup_mutex);
>  -               call_usermodehelper(argv[0], argv, envp, UMH_WAIT_EXEC);
>  +
>  +retry:
>  +               err = call_usermodehelper(argv[0], argv, envp, UMH_WAIT_EXEC);
>  +               if (err == -ENOMEM) {
>  +                       schedule();
>  +                       goto retry;
>  +               }

I'm not sure that an infinite loop retry is a great idea. Assuming
that call_usermodehelper() is changed to not use GFP_ATOMIC (which
should be safe at least in the case when UMG_WAIT_EXEC is set, since
we can clearly sleep in that case) then I'd be inclined not to check.
If we're so low on memory that we can't fork/exec, then the helper
binary itself could just as easily OOM as soon as we've launched it.
So there's still no guarantee. Userspace should just have to check for
empty cgroups occasionally even if they are using notify_on_release.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
