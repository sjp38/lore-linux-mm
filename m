Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E0C526B0062
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 05:45:13 -0400 (EDT)
Message-ID: <351740.68168.qm@web15302.mail.cnb.yahoo.com>
Date: Mon, 30 Mar 2009 17:45:52 +0800 (CST)
From: HongChao Zhang <zhanghc08@yahoo.com.cn>
Subject: Problem in "prune_icache"
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="0-396024045-1238406352=:68168"
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


--0-396024045-1238406352=:68168
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: quoted-printable

Hi
=20
I'am from Lustre, which is a product of SUN Mirocsystem to implement
Scaled Distributed FileSystem, and we encounter a deadlock problem=20
in prune_icache, the detailed is,
=20
during truncating a file, a new update in current journal transaction
will be created, but it found memory in low level during processing,=20
then it call try_to_free_pages to free some pages, which finially call
shrink_icache_memory/prune_icache to free cache memory occupied by inodes.
Note: prune_icache will get and hold "iprune_mutex" during its whole prunin=
g work.
=20
but at the same time, kswapd have called shrink_icache_memory/prune_icache =
with=20
"iprune_mutex" locked, which found some inodes to dispose and call=20
clear_inode/DQUOT_DROP/fs-specific-quota-drop-op(say "ldiskfs_dquot_drop" i=
n our case)
to drop dquot, and this fs-specific-quota-drop-op can call journal_start to
start a new update, but it found the buffers in current transaction is up t=
o
j_max_transaction_buffers, so it wake up kjournald to commit the transactio=
n.
so kjournald will call journal_commit_transaction to commit the transcation=
,
which set the state of the transaction as T_LOCKED then check whether there=
 are
still pending updates for the committing transaction, and it found there is=
 a
pending update(started in truncating operation, see above), so it will wait
the update to complete, BUT the update won't be completed for it can't get =
the
"iprune_mutex" hold by kswapd, so the deadlock is triggered.
=20
please see attachment for the possible patch to fixup this problem.
=20

Regards
Hongchao=0A=0A=0A      ____________________________________________________=
_______ =0A  =BA=C3=CD=E6=BA=D8=BF=A8=B5=C8=C4=E3=B7=A2=A3=AC=D3=CA=CF=E4=
=BA=D8=BF=A8=C8=AB=D0=C2=C9=CF=CF=DF=A3=A1 =0Ahttp://card.mail.cn.yahoo.com=
/
--0-396024045-1238406352=:68168
Content-Type: text/plain; name="patch.18399"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="patch.18399"

LS0tIGZzL2lub2RlLmMub3JpZwkyMDA5LTAxLTI0IDAzOjI4OjU3LjAwMDAw
MDAwMCArMDgwMAorKysgZnMvaW5vZGUuYwkyMDA5LTAxLTI0IDAzOjMwOjE4
LjAwMDAwMDAwMCArMDgwMApAQCAtNDE4LDcgKzQxOCw5IEBAIHN0YXRpYyB2
b2lkIHBydW5lX2ljYWNoZShpbnQgbnJfdG9fc2NhbikKIAlpbnQgbnJfc2Nh
bm5lZDsKIAl1bnNpZ25lZCBsb25nIHJlYXAgPSAwOwogCi0JbXV0ZXhfbG9j
aygmaXBydW5lX211dGV4KTsKKwlpZiAoIW11dGV4X3RyeWxvY2soJmlwcnVu
ZV9tdXRleCkpCisJCXJldHVybjsKKwogCXNwaW5fbG9jaygmaW5vZGVfbG9j
ayk7CiAJZm9yIChucl9zY2FubmVkID0gMDsgbnJfc2Nhbm5lZCA8IG5yX3Rv
X3NjYW47IG5yX3NjYW5uZWQrKykgewogCQlzdHJ1Y3QgaW5vZGUgKmlub2Rl
Owo=

--0-396024045-1238406352=:68168--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
