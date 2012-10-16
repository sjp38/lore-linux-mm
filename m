Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 3DE0B6B0044
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 02:10:40 -0400 (EDT)
From: Sha Zhengju <handai.szj@taobao.com>
Subject: [PATCH] oom, memcg: handle sysctl oom_kill_allocating_task while memcg oom happening
Date: Tue, 16 Oct 2012 14:10:37 +0800
Message-ID: <1350367837-27919-1-git-send-email-handai.szj@taobao.com>
MIME-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, mhocko@suse.cz
Cc: linux-kernel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

From: Sha Zhengju <handai.szj@taobao.com>

Sysctl oom_kill_allocating_task enables or disables killing the OOM-trigger=
ing
task in out-of-memory situations, but it only works on overall system-wide =
oom.
But it's also a useful indication in memcg so we take it into consideration
while oom happening in memcg. Other sysctl such as panic_on_oom has already
been memcg-ware.


Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
---
 mm/oom_kill.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 38129e3..2a176af 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -574,6 +574,18 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *memcg=
, gfp_t gfp_mask)
        check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, 0, NULL);
        limit =3D mem_cgroup_get_limit(memcg) >> PAGE_SHIFT;
        read_lock(&tasklist_lock);
+       if (sysctl_oom_kill_allocating_task &&
+           !oom_unkillable_task(current, memcg, NULL) &&
+           current->mm) {
+               /*
+                * oom_kill_process() needs tasklist_lock held.  If it retu=
rns
+                * non-zero, current could not be killed so we must fallbac=
k to
+                * the tasklist scan.
+                */
+               if (!oom_kill_process(current, gfp_mask, 0, 0, limit, memcg=
, NULL,
+                               "Memory cgroup out of memory (oom_kill_allo=
cating_task)"))
+                       goto out;
+       }
 retry:
        p =3D select_bad_process(&points, limit, memcg, NULL);
        if (!p || PTR_ERR(p) =3D=3D -1UL)
--
1.7.6.1


________________________________

This email (including any attachments) is confidential and may be legally p=
rivileged. If you received this email in error, please delete it immediatel=
y and do not copy it or use it for any purpose or disclose its contents to =
any other person. Thank you.

=B1=BE=B5=E7=D3=CA(=B0=FC=C0=A8=C8=CE=BA=CE=B8=BD=BC=FE)=BF=C9=C4=DC=BA=AC=
=D3=D0=BB=FA=C3=DC=D7=CA=C1=CF=B2=A2=CA=DC=B7=A8=C2=C9=B1=A3=BB=A4=A1=A3=C8=
=E7=C4=FA=B2=BB=CA=C7=D5=FD=C8=B7=B5=C4=CA=D5=BC=FE=C8=CB=A3=AC=C7=EB=C4=FA=
=C1=A2=BC=B4=C9=BE=B3=FD=B1=BE=D3=CA=BC=FE=A1=A3=C7=EB=B2=BB=D2=AA=BD=AB=B1=
=BE=B5=E7=D3=CA=BD=F8=D0=D0=B8=B4=D6=C6=B2=A2=D3=C3=D7=F7=C8=CE=BA=CE=C6=E4=
=CB=FB=D3=C3=CD=BE=A1=A2=BB=F2=CD=B8=C2=B6=B1=BE=D3=CA=BC=FE=D6=AE=C4=DA=C8=
=DD=A1=A3=D0=BB=D0=BB=A1=A3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
