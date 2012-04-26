Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 78B076B004A
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 18:19:25 -0400 (EDT)
Message-ID: <4F99C980.3030801@parallels.com>
Date: Thu, 26 Apr 2012 19:17:36 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 2/2] decrement static keys on real destroy time
References: <1335475463-25167-1-git-send-email-glommer@parallels.com> <1335475463-25167-3-git-send-email-glommer@parallels.com> <20120426213916.GD27486@google.com> <4F99C50D.6070503@parallels.com> <20120426221324.GE27486@google.com>
In-Reply-To: <20120426221324.GE27486@google.com>
Content-Type: multipart/mixed;
	boundary="------------090600080104080606040603"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: cgroups@vger.kernel.org, netdev@vger.kernel.org, Li Zefan <lizefan@huawei.com>, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, devel@openvz.org

--------------090600080104080606040603
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit


> No, what I mean is that why can't you do about the same mutexed
> activated inside static_key API function instead of requiring every
> user to worry about the function returning asynchronously.
> ie. synchronize inside static_key API instead of in the callers.
>

Like this?



--------------090600080104080606040603
Content-Type: text/x-patch; name="jump_label.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="jump_label.patch"

diff --git a/kernel/jump_label.c b/kernel/jump_label.c
index 4304919..f7cdc18 100644
--- a/kernel/jump_label.c
+++ b/kernel/jump_label.c
@@ -57,10 +57,11 @@ static void jump_label_update(struct static_key *key, int enable);
 
 void static_key_slow_inc(struct static_key *key)
 {
+	jump_label_lock();
+
 	if (atomic_inc_not_zero(&key->enabled))
-		return;
+		goto out;
 
-	jump_label_lock();
 	if (atomic_read(&key->enabled) == 0) {
 		if (!jump_label_get_branch_default(key))
 			jump_label_update(key, JUMP_LABEL_ENABLE);
@@ -68,6 +69,7 @@ void static_key_slow_inc(struct static_key *key)
 			jump_label_update(key, JUMP_LABEL_DISABLE);
 	}
 	atomic_inc(&key->enabled);
+out:
 	jump_label_unlock();
 }
 EXPORT_SYMBOL_GPL(static_key_slow_inc);
@@ -75,10 +77,11 @@ EXPORT_SYMBOL_GPL(static_key_slow_inc);
 static void __static_key_slow_dec(struct static_key *key,
 		unsigned long rate_limit, struct delayed_work *work)
 {
-	if (!atomic_dec_and_mutex_lock(&key->enabled, &jump_label_mutex)) {
+	jump_label_lock();
+	if (atomic_dec_and_test(&key->enabled)) {
 		WARN(atomic_read(&key->enabled) < 0,
 		     "jump label: negative count!\n");
-		return;
+		goto out;
 	}
 
 	if (rate_limit) {
@@ -90,6 +93,8 @@ static void __static_key_slow_dec(struct static_key *key,
 		else
 			jump_label_update(key, JUMP_LABEL_ENABLE);
 	}
+
+out:
 	jump_label_unlock();
 }
 

--------------090600080104080606040603--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
