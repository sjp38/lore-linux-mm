Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8363F6B025F
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 20:57:09 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id c21so2828753qkg.0
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 17:57:09 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 133sor685583qkj.114.2018.02.21.17.57.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Feb 2018 17:57:08 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v12 14/22] selftests/vm: clear the bits in shadow reg when a pkey is freed.
Date: Wed, 21 Feb 2018 17:55:33 -0800
Message-Id: <1519264541-7621-15-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1519264541-7621-1-git-send-email-linuxram@us.ibm.com>
References: <1519264541-7621-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@redhat.com, akpm@linux-foundation.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com, arnd@arndb.de

When a key is freed, the  key  is  no  more  effective.
Clear the bits corresponding to the pkey in the shadow
register. Otherwise  it  will carry some spurious bits
which can trigger false-positive asserts.

cc: Dave Hansen <dave.hansen@intel.com>
cc: Florian Weimer <fweimer@redhat.com>
Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 tools/testing/selftests/vm/protection_keys.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/tools/testing/selftests/vm/protection_keys.c b/tools/testing/selftests/vm/protection_keys.c
index c4c73e6..e82bd88 100644
--- a/tools/testing/selftests/vm/protection_keys.c
+++ b/tools/testing/selftests/vm/protection_keys.c
@@ -586,7 +586,8 @@ int sys_pkey_free(unsigned long pkey)
 	int ret = syscall(SYS_pkey_free, pkey);
 
 	if (!ret)
-		shadow_pkey_reg &= reset_bits(pkey, PKEY_DISABLE_ACCESS);
+		shadow_pkey_reg &= reset_bits(pkey,
+				PKEY_DISABLE_ACCESS | PKEY_DISABLE_WRITE);
 	dprintf1("%s(pkey=%ld) syscall ret: %d\n", __func__, pkey, ret);
 	return ret;
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
