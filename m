Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id E44326B006E
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 11:12:23 -0400 (EDT)
Received: by oiww2 with SMTP id w2so127950575oiw.0
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 08:12:23 -0700 (PDT)
Received: from mail-oi0-x232.google.com (mail-oi0-x232.google.com. [2607:f8b0:4003:c06::232])
        by mx.google.com with ESMTPS id ph16si657159oeb.99.2015.06.02.08.12.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jun 2015 08:12:22 -0700 (PDT)
Received: by oifu123 with SMTP id u123so127974409oif.1
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 08:12:22 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH 2/5] module: add per-module params lock
Date: Tue,  2 Jun 2015 11:11:54 -0400
Message-Id: <1433257917-13090-3-git-send-email-ddstreet@ieee.org>
In-Reply-To: <1433257917-13090-1-git-send-email-ddstreet@ieee.org>
References: <1433257917-13090-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>, Rusty Russell <rusty@rustcorp.com.au>
Cc: Christoph Hellwig <hch@infradead.org>, Jani Nikula <jani.nikula@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Streetman <ddstreet@ieee.org>

Add a "param_lock" mutex to each module, and add a pointer to the owning
module to struct kernel_param.  Then change the param sysfs modification
code to only use the global param_lock for built-ins, and use the
per-module param_lock for all modules.  Also simplify the
kernel_[un]block_sysfs_[read|write]() functions, to simply
kernel_[un]block_sysfs().

The kernel param code currently uses a single global mutex to protect
modification of any and all kernel params.  While this generally works,
there is one specific problem with it; a module callback function
cannot safely load another module, i.e. with request_module() or even
with indirect calls such as crypto_has_alg().  If the module to be
loaded has any of its params configured (e.g. with a /etc/modprobe.d/*
config file), then the attempt will result in a deadlock between the
first module param callback waiting for modprobe, and modprobe trying to
lock the global kernel param mutex to set the new module's param.

This fixes that by using per-module mutexes, so that each individual module
is protected against concurrent changes in its own kernel params, but is
not blocked by changes to other module params.  All built-in modules
continue to use the global mutex, since they will always be loaded at
runtime and references (e.g. request_module(), crypto_has_alg()) to them
will never cause load-time param changing.

This also simplifies the interface used by modules to block sysfs access
to their params; while there are currently functions to block and unblock
sysfs param access which are split up by read and write and expect a single
kernel param to be passed, their actual operation is identical and applies
to all params, not just the one passed to them; they simply lock and unlock
the global param mutex.  They are thus replaced with simplified functions
that clearly indicate that all params for a module are being blocked, both
for read and write access.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
---
 arch/um/drivers/hostaudio_kern.c                 | 20 +++----
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c |  6 +--
 drivers/net/wireless/libertas_tf/if_usb.c        |  6 +--
 drivers/usb/atm/ueagle-atm.c                     |  4 +-
 drivers/video/fbdev/vt8623fb.c                   |  4 +-
 include/linux/module.h                           |  1 +
 include/linux/moduleparam.h                      | 67 +++++++++---------------
 kernel/module.c                                  |  1 +
 kernel/params.c                                  | 45 ++++++++++------
 net/mac80211/rate.c                              |  4 +-
 10 files changed, 77 insertions(+), 81 deletions(-)

diff --git a/arch/um/drivers/hostaudio_kern.c b/arch/um/drivers/hostaudio_kern.c
index 9b90fdc..1bcb798 100644
--- a/arch/um/drivers/hostaudio_kern.c
+++ b/arch/um/drivers/hostaudio_kern.c
@@ -185,9 +185,9 @@ static int hostaudio_open(struct inode *inode, struct file *file)
 	int ret;
 
 #ifdef DEBUG
-	kparam_block_sysfs_write(dsp);
+	kparam_block_sysfs();
 	printk(KERN_DEBUG "hostaudio: open called (host: %s)\n", dsp);
-	kparam_unblock_sysfs_write(dsp);
+	kparam_unblock_sysfs();
 #endif
 
 	state = kmalloc(sizeof(struct hostaudio_state), GFP_KERNEL);
@@ -199,11 +199,11 @@ static int hostaudio_open(struct inode *inode, struct file *file)
 	if (file->f_mode & FMODE_WRITE)
 		w = 1;
 
-	kparam_block_sysfs_write(dsp);
+	kparam_block_sysfs();
 	mutex_lock(&hostaudio_mutex);
 	ret = os_open_file(dsp, of_set_rw(OPENFLAGS(), r, w), 0);
 	mutex_unlock(&hostaudio_mutex);
-	kparam_unblock_sysfs_write(dsp);
+	kparam_unblock_sysfs();
 
 	if (ret < 0) {
 		kfree(state);
@@ -260,17 +260,17 @@ static int hostmixer_open_mixdev(struct inode *inode, struct file *file)
 	if (file->f_mode & FMODE_WRITE)
 		w = 1;
 
-	kparam_block_sysfs_write(mixer);
+	kparam_block_sysfs();
 	mutex_lock(&hostaudio_mutex);
 	ret = os_open_file(mixer, of_set_rw(OPENFLAGS(), r, w), 0);
 	mutex_unlock(&hostaudio_mutex);
-	kparam_unblock_sysfs_write(mixer);
+	kparam_unblock_sysfs();
 
 	if (ret < 0) {
-		kparam_block_sysfs_write(dsp);
+		kparam_block_sysfs();
 		printk(KERN_ERR "hostaudio_open_mixdev failed to open '%s', "
 		       "err = %d\n", dsp, -ret);
-		kparam_unblock_sysfs_write(dsp);
+		kparam_unblock_sysfs();
 		kfree(state);
 		return ret;
 	}
@@ -326,10 +326,10 @@ MODULE_LICENSE("GPL");
 
 static int __init hostaudio_init_module(void)
 {
-	__kernel_param_lock();
+	kparam_block_sysfs();
 	printk(KERN_INFO "UML Audio Relay (host dsp = %s, host mixer = %s)\n",
 	       dsp, mixer);
-	__kernel_param_unlock();
+	kparam_unblock_sysfs();
 
 	module_data.dev_audio = register_sound_dsp(&hostaudio_fops, -1);
 	if (module_data.dev_audio < 0) {
diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index 2bae502..6d7ac3f 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -279,7 +279,7 @@ MODULE_FIRMWARE("myri10ge_eth_z8e.dat");
 MODULE_FIRMWARE("myri10ge_rss_ethp_z8e.dat");
 MODULE_FIRMWARE("myri10ge_rss_eth_z8e.dat");
 
-/* Careful: must be accessed under kparam_block_sysfs_write */
+/* Careful: must be accessed under kparam_block_sysfs */
 static char *myri10ge_fw_name = NULL;
 module_param(myri10ge_fw_name, charp, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(myri10ge_fw_name, "Firmware image name");
@@ -3427,7 +3427,7 @@ static void myri10ge_select_firmware(struct myri10ge_priv *mgp)
 		}
 	}
 
-	kparam_block_sysfs_write(myri10ge_fw_name);
+	kparam_block_sysfs();
 	if (myri10ge_fw_name != NULL) {
 		char *fw_name = kstrdup(myri10ge_fw_name, GFP_KERNEL);
 		if (fw_name) {
@@ -3435,7 +3435,7 @@ static void myri10ge_select_firmware(struct myri10ge_priv *mgp)
 			set_fw_name(mgp, fw_name, true);
 		}
 	}
-	kparam_unblock_sysfs_write(myri10ge_fw_name);
+	kparam_unblock_sysfs();
 
 	if (mgp->board_number < MYRI10GE_MAX_BOARDS &&
 	    myri10ge_fw_names[mgp->board_number] != NULL &&
diff --git a/drivers/net/wireless/libertas_tf/if_usb.c b/drivers/net/wireless/libertas_tf/if_usb.c
index 1a20cee..7cdbbce 100644
--- a/drivers/net/wireless/libertas_tf/if_usb.c
+++ b/drivers/net/wireless/libertas_tf/if_usb.c
@@ -821,15 +821,15 @@ static int if_usb_prog_firmware(struct if_usb_card *cardp)
 
 	lbtf_deb_enter(LBTF_DEB_USB);
 
-	kparam_block_sysfs_write(fw_name);
+	kparam_block_sysfs();
 	ret = request_firmware(&cardp->fw, lbtf_fw_name, &cardp->udev->dev);
 	if (ret < 0) {
 		pr_err("request_firmware() failed with %#x\n", ret);
 		pr_err("firmware %s not found\n", lbtf_fw_name);
-		kparam_unblock_sysfs_write(fw_name);
+		kparam_unblock_sysfs();
 		goto done;
 	}
-	kparam_unblock_sysfs_write(fw_name);
+	kparam_unblock_sysfs();
 
 	if (check_fwfile_format(cardp->fw->data, cardp->fw->size))
 		goto release_fw;
diff --git a/drivers/usb/atm/ueagle-atm.c b/drivers/usb/atm/ueagle-atm.c
index 888998a..8262989 100644
--- a/drivers/usb/atm/ueagle-atm.c
+++ b/drivers/usb/atm/ueagle-atm.c
@@ -1599,7 +1599,7 @@ static void cmvs_file_name(struct uea_softc *sc, char *const cmv_name, int ver)
 	char file_arr[] = "CMVxy.bin";
 	char *file;
 
-	kparam_block_sysfs_write(cmv_file);
+	kparam_block_sysfs();
 	/* set proper name corresponding modem version and line type */
 	if (cmv_file[sc->modem_index] == NULL) {
 		if (UEA_CHIP_VERSION(sc) == ADI930)
@@ -1618,7 +1618,7 @@ static void cmvs_file_name(struct uea_softc *sc, char *const cmv_name, int ver)
 	strlcat(cmv_name, file, UEA_FW_NAME_MAX);
 	if (ver == 2)
 		strlcat(cmv_name, ".v2", UEA_FW_NAME_MAX);
-	kparam_unblock_sysfs_write(cmv_file);
+	kparam_unblock_sysfs();
 }
 
 static int request_cmvs_old(struct uea_softc *sc,
diff --git a/drivers/video/fbdev/vt8623fb.c b/drivers/video/fbdev/vt8623fb.c
index ea7f056..a940626 100644
--- a/drivers/video/fbdev/vt8623fb.c
+++ b/drivers/video/fbdev/vt8623fb.c
@@ -754,9 +754,9 @@ static int vt8623_pci_probe(struct pci_dev *dev, const struct pci_device_id *id)
 
 	/* Prepare startup mode */
 
-	kparam_block_sysfs_write(mode_option);
+	kparam_block_sysfs();
 	rc = fb_find_mode(&(info->var), info, mode_option, NULL, 0, NULL, 8);
-	kparam_unblock_sysfs_write(mode_option);
+	kparam_unblock_sysfs();
 	if (! ((rc == 1) || (rc == 2))) {
 		rc = -EINVAL;
 		dev_err(info->device, "mode %s not found\n", mode_option);
diff --git a/include/linux/module.h b/include/linux/module.h
index c883b86..e8c24d8 100644
--- a/include/linux/module.h
+++ b/include/linux/module.h
@@ -232,6 +232,7 @@ struct module {
 	unsigned int num_syms;
 
 	/* Kernel parameters. */
+	struct mutex param_lock;
 	struct kernel_param *kp;
 	unsigned int num_kp;
 
diff --git a/include/linux/moduleparam.h b/include/linux/moduleparam.h
index 1c9effa..d9f689f 100644
--- a/include/linux/moduleparam.h
+++ b/include/linux/moduleparam.h
@@ -67,6 +67,7 @@ enum {
 
 struct kernel_param {
 	const char *name;
+	struct module *mod;
 	const struct kernel_param_ops *ops;
 	u16 perm;
 	s8 level;
@@ -108,7 +109,7 @@ struct kparam_array
  *
  * @perm is 0 if the the variable is not to appear in sysfs, or 0444
  * for world-readable, 0644 for root-writable, etc.  Note that if it
- * is writable, you may need to use kparam_block_sysfs_write() around
+ * is writable, you may need to use kparam_block_sysfs() around
  * accesses (esp. charp, which can be kfreed when it changes).
  *
  * The @type is simply pasted to refer to a param_ops_##type and a
@@ -220,8 +221,8 @@ struct kparam_array
 	static struct kernel_param __moduleparam_const __param_##name	\
 	__used								\
     __attribute__ ((unused,__section__ ("__param"),aligned(sizeof(void *)))) \
-	= { __param_str_##name, ops, VERIFY_OCTAL_PERMISSIONS(perm),	\
-	    level, flags, { arg } }
+	= { __param_str_##name, THIS_MODULE, ops,			\
+	    VERIFY_OCTAL_PERMISSIONS(perm), level, flags, { arg } }
 
 /* Obsolete - use module_param_cb() */
 #define module_param_call(name, set, get, arg, perm)			\
@@ -239,57 +240,37 @@ __check_old_set_param(int (*oldset)(const char *, struct kernel_param *))
 }
 
 /**
- * kparam_block_sysfs_write - make sure a parameter isn't written via sysfs.
- * @name: the name of the parameter
+ * kparam_block_sysfs - lock THIS_MODULE's param(s) from being r/w
  *
- * There's no point blocking write on a paramter that isn't writable via sysfs!
- */
-#define kparam_block_sysfs_write(name)			\
-	do {						\
-		BUG_ON(!(__param_##name.perm & 0222));	\
-		__kernel_param_lock();			\
-	} while (0)
-
-/**
- * kparam_unblock_sysfs_write - allows sysfs to write to a parameter again.
- * @name: the name of the parameter
- */
-#define kparam_unblock_sysfs_write(name)		\
-	do {						\
-		BUG_ON(!(__param_##name.perm & 0222));	\
-		__kernel_param_unlock();		\
-	} while (0)
-
-/**
- * kparam_block_sysfs_read - make sure a parameter isn't read via sysfs.
- * @name: the name of the parameter
+ * Each module has its own mutex that protects all of its sysfs params
+ * during read and write from sysfs of any of its params.  All built-ins
+ * share a single mutex that similarly protects all built-in sysfs params.
+ * This locks the appropriate mutex; either the built-in mutex if called
+ * from a built-in, or the specific module's mutex if called from a module.
  *
- * This also blocks sysfs writes.
+ * As with any mutex, this call will block if any of the corresponding
+ * param(s) are currently being read or written.  After calling this, the
+ * @kparam_unblock_sysfs() function must be called to unlock the mutex and
+ * allow the corresponding param(s) to be read and written.
  */
-#define kparam_block_sysfs_read(name)			\
-	do {						\
-		BUG_ON(!(__param_##name.perm & 0444));	\
-		__kernel_param_lock();			\
-	} while (0)
+#define kparam_block_sysfs()	__kernel_param_lock(THIS_MODULE)
 
 /**
- * kparam_unblock_sysfs_read - allows sysfs to read a parameter again.
- * @name: the name of the parameter
+ * kparam_unblock_sysfs - unlock THIS_MODULE's param(s) from being r/w
+ *
+ * This unlocks the corresponding mutex; see @kparam_block_sysfs() for details.
  */
-#define kparam_unblock_sysfs_read(name)			\
-	do {						\
-		BUG_ON(!(__param_##name.perm & 0444));	\
-		__kernel_param_unlock();		\
-	} while (0)
+#define kparam_unblock_sysfs()	__kernel_param_unlock(THIS_MODULE)
 
 #ifdef CONFIG_SYSFS
-extern void __kernel_param_lock(void);
-extern void __kernel_param_unlock(void);
+/* don't use these directly, use block/unblock_sysfs above */
+extern void __kernel_param_lock(struct module *);
+extern void __kernel_param_unlock(struct module *);
 #else
-static inline void __kernel_param_lock(void)
+static inline void __kernel_param_lock(struct module *)
 {
 }
-static inline void __kernel_param_unlock(void)
+static inline void __kernel_param_unlock(struct module *)
 {
 }
 #endif
diff --git a/kernel/module.c b/kernel/module.c
index 42a1d2a..d3632e7 100644
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -3341,6 +3341,7 @@ static int load_module(struct load_info *info, const char __user *uargs,
 		goto ddebug_cleanup;
 
 	/* Module is ready to execute: parsing args may do that. */
+	mutex_init(&mod->param_lock);
 	after_dashes = parse_args(mod->name, mod->args, mod->kp, mod->num_kp,
 				  -32768, 32767, unknown_module_param_cb);
 	if (IS_ERR(after_dashes)) {
diff --git a/kernel/params.c b/kernel/params.c
index a22d6a7..2d1849b 100644
--- a/kernel/params.c
+++ b/kernel/params.c
@@ -25,8 +25,9 @@
 #include <linux/slab.h>
 #include <linux/ctype.h>
 
-/* Protects all parameters, and incidentally kmalloced_param list. */
+/* Protects all built-in parameters; modules use their own param_lock */
 static DEFINE_MUTEX(param_lock);
+static bool __kernel_param_is_locked(struct module *mod);
 
 /* This just allows us to keep track of which parameters are kmalloced. */
 struct kmalloced_param {
@@ -34,6 +35,7 @@ struct kmalloced_param {
 	char val[];
 };
 static LIST_HEAD(kmalloced_params);
+static DEFINE_SPINLOCK(kmalloced_params_lock);
 
 static void *kmalloc_parameter(unsigned int size)
 {
@@ -43,7 +45,10 @@ static void *kmalloc_parameter(unsigned int size)
 	if (!p)
 		return NULL;
 
+	spin_lock(&kmalloced_params_lock);
 	list_add(&p->list, &kmalloced_params);
+	spin_unlock(&kmalloced_params_lock);
+
 	return p->val;
 }
 
@@ -52,6 +57,7 @@ static void maybe_kfree_parameter(void *param)
 {
 	struct kmalloced_param *p;
 
+	spin_lock(&kmalloced_params_lock);
 	list_for_each_entry(p, &kmalloced_params, list) {
 		if (p->val == param) {
 			list_del(&p->list);
@@ -59,6 +65,7 @@ static void maybe_kfree_parameter(void *param)
 			break;
 		}
 	}
+	spin_unlock(&kmalloced_params_lock);
 }
 
 static char dash2underscore(char c)
@@ -118,10 +125,10 @@ static int parse_one(char *param,
 				return -EINVAL;
 			pr_debug("handling %s with %p\n", param,
 				params[i].ops->set);
-			mutex_lock(&param_lock);
+			__kernel_param_lock(params[i].mod);
 			param_check_unsafe(&params[i]);
 			err = params[i].ops->set(val, &params[i]);
-			mutex_unlock(&param_lock);
+			__kernel_param_unlock(params[i].mod);
 			return err;
 		}
 	}
@@ -387,7 +394,8 @@ struct kernel_param_ops param_ops_bint = {
 EXPORT_SYMBOL(param_ops_bint);
 
 /* We break the rule and mangle the string. */
-static int param_array(const char *name,
+static int param_array(struct module *mod,
+		       const char *name,
 		       const char *val,
 		       unsigned int min, unsigned int max,
 		       void *elem, int elemsize,
@@ -418,7 +426,7 @@ static int param_array(const char *name,
 		/* nul-terminate and parse */
 		save = val[len];
 		((char *)val)[len] = '\0';
-		BUG_ON(!mutex_is_locked(&param_lock));
+		BUG_ON(!__kernel_param_is_locked(mod));
 		ret = set(val, &kp);
 
 		if (ret != 0)
@@ -440,7 +448,7 @@ static int param_array_set(const char *val, const struct kernel_param *kp)
 	const struct kparam_array *arr = kp->arr;
 	unsigned int temp_num;
 
-	return param_array(kp->name, val, 1, arr->max, arr->elem,
+	return param_array(kp->mod, kp->name, val, 1, arr->max, arr->elem,
 			   arr->elemsize, arr->ops->set, kp->level,
 			   arr->num ?: &temp_num);
 }
@@ -456,7 +464,7 @@ static int param_array_get(char *buffer, const struct kernel_param *kp)
 		if (i)
 			buffer[off++] = ',';
 		p.arg = arr->elem + arr->elemsize * i;
-		BUG_ON(!mutex_is_locked(&param_lock));
+		BUG_ON(!__kernel_param_is_locked(kp->mod));
 		ret = arr->ops->get(buffer + off, &p);
 		if (ret < 0)
 			return ret;
@@ -539,9 +547,9 @@ static ssize_t param_attr_show(struct module_attribute *mattr,
 	if (!attribute->param->ops->get)
 		return -EPERM;
 
-	mutex_lock(&param_lock);
+	__kernel_param_lock(mk->mod);
 	count = attribute->param->ops->get(buf, attribute->param);
-	mutex_unlock(&param_lock);
+	__kernel_param_unlock(mk->mod);
 	if (count > 0) {
 		strcat(buf, "\n");
 		++count;
@@ -551,7 +559,7 @@ static ssize_t param_attr_show(struct module_attribute *mattr,
 
 /* sysfs always hands a nul-terminated string in buf.  We rely on that. */
 static ssize_t param_attr_store(struct module_attribute *mattr,
-				struct module_kobject *km,
+				struct module_kobject *mk,
 				const char *buf, size_t len)
 {
  	int err;
@@ -560,10 +568,10 @@ static ssize_t param_attr_store(struct module_attribute *mattr,
 	if (!attribute->param->ops->set)
 		return -EPERM;
 
-	mutex_lock(&param_lock);
+	__kernel_param_lock(mk->mod);
 	param_check_unsafe(attribute->param);
 	err = attribute->param->ops->set(buf, attribute->param);
-	mutex_unlock(&param_lock);
+	__kernel_param_unlock(mk->mod);
 	if (!err)
 		return len;
 	return err;
@@ -576,16 +584,21 @@ static ssize_t param_attr_store(struct module_attribute *mattr,
 #define __modinit __init
 #endif
 
+static bool __kernel_param_is_locked(struct module *mod)
+{
+	return mutex_is_locked(mod ? &mod->param_lock : &param_lock);
+}
+
 #ifdef CONFIG_SYSFS
-void __kernel_param_lock(void)
+void __kernel_param_lock(struct module *mod)
 {
-	mutex_lock(&param_lock);
+	mutex_lock(mod ? &mod->param_lock : &param_lock);
 }
 EXPORT_SYMBOL(__kernel_param_lock);
 
-void __kernel_param_unlock(void)
+void __kernel_param_unlock(struct module *mod)
 {
-	mutex_unlock(&param_lock);
+	mutex_unlock(mod ? &mod->param_lock : &param_lock);
 }
 EXPORT_SYMBOL(__kernel_param_unlock);
 
diff --git a/net/mac80211/rate.c b/net/mac80211/rate.c
index d53355b..ca82d5e 100644
--- a/net/mac80211/rate.c
+++ b/net/mac80211/rate.c
@@ -103,7 +103,7 @@ ieee80211_rate_control_ops_get(const char *name)
 	const struct rate_control_ops *ops;
 	const char *alg_name;
 
-	kparam_block_sysfs_write(ieee80211_default_rc_algo);
+	kparam_block_sysfs();
 	if (!name)
 		alg_name = ieee80211_default_rc_algo;
 	else
@@ -117,7 +117,7 @@ ieee80211_rate_control_ops_get(const char *name)
 	/* try built-in one if specific alg requested but not found */
 	if (!ops && strlen(CONFIG_MAC80211_RC_DEFAULT))
 		ops = ieee80211_try_rate_control_ops_get(CONFIG_MAC80211_RC_DEFAULT);
-	kparam_unblock_sysfs_write(ieee80211_default_rc_algo);
+	kparam_unblock_sysfs();
 
 	return ops;
 }
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
