Return-Path: <SRS0=7uET=XD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_2 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 144E8C49ED4
	for <linux-mm@archiver.kernel.org>; Sun,  8 Sep 2019 16:36:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD05B218AC
	for <linux-mm@archiver.kernel.org>; Sun,  8 Sep 2019 16:36:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD05B218AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F9886B0003; Sun,  8 Sep 2019 12:36:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 484756B0006; Sun,  8 Sep 2019 12:36:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 324496B0007; Sun,  8 Sep 2019 12:36:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0053.hostedemail.com [216.40.44.53])
	by kanga.kvack.org (Postfix) with ESMTP id 01F2C6B0003
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 12:36:06 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 77E1B180AD7C3
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 16:36:06 +0000 (UTC)
X-FDA: 75912305532.04.beef14_525778fa2e60e
X-HE-Tag: beef14_525778fa2e60e
X-Filterd-Recvd-Size: 17739
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com [148.163.156.1])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 16:36:05 +0000 (UTC)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x88GWMPk035620
	for <linux-mm@kvack.org>; Sun, 8 Sep 2019 12:36:03 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2uw3xwhmq5-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 08 Sep 2019 12:36:03 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zohar@linux.ibm.com>;
	Sun, 8 Sep 2019 17:36:01 +0100
Received: from b06avi18626390.portsmouth.uk.ibm.com (9.149.26.192)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Sun, 8 Sep 2019 17:35:58 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06avi18626390.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x88GZXoO39322056
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sun, 8 Sep 2019 16:35:33 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id DB4984C040;
	Sun,  8 Sep 2019 16:35:57 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 0965D4C044;
	Sun,  8 Sep 2019 16:35:57 +0000 (GMT)
Received: from localhost.localdomain (unknown [9.85.159.93])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Sun,  8 Sep 2019 16:35:56 +0000 (GMT)
Subject: Re: [PATCH 1/3] ima: keep the integrity state of open files up to
 date
From: Mimi Zohar <zohar@linux.ibm.com>
To: Janne Karhunen <janne.karhunen@gmail.com>, linux-integrity@vger.kernel.org,
        linux-security-module@vger.kernel.org, linux-mm@kvack.org,
        viro@zeniv.linux.org.uk
Cc: Konsta Karsisto <konsta.karsisto@gmail.com>
Date: Sun, 08 Sep 2019 12:35:53 -0400
In-Reply-To: <20190902094540.12786-1-janne.karhunen@gmail.com>
References: <20190902094540.12786-1-janne.karhunen@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.20.5 (3.20.5-1.fc24) 
Mime-Version: 1.0
X-TM-AS-GCONF: 00
x-cbid: 19090816-0020-0000-0000-000003696689
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19090816-0021-0000-0000-000021BEE480
Message-Id: <1567960553.4614.180.camel@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-09-08_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1909080181
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-09-02 at 12:45 +0300, Janne Karhunen wrote:
> When a file is open for writing, kernel crash or power outage
> is guaranteed to corrupt the inode integrity state leading to
> file appraisal failure on the subsequent boot. Add some basic
> infrastructure to keep the integrity measurements up to date
> as the files are written to.

The term "measurement" refers to the file hash stored in the IMA
measurement list and used to extend the TPM. =C2=A0IMA-appraisal verifies
the file hash against a known good value stored as an extended
attribute(xattr). =C2=A0For immutable files, the known good value should =
be
a file signature. =C2=A0For mutable files, the known good value is a file
hash. =C2=A0The purpose of this patch set is to increase the frequency in
which the file hash, stored as an xattr, is updated.

Throughout this patch set the term "measurement" or "measure" is
inappropriately used.

>=20
> Core file operations (open, close, sync, msync, truncate) are
> now allowed to update the measurement immediately. In order
> to maintain sufficient write performance for writes, add a
> latency tunable delayed work workqueue for computing the
> measurements.
>=20
> Changelog v2:
> - Make write measurements optional
> - Add support for MMIO measurements
> - Handle all writes via page flush
> - Add work cancellation support, files are properly closed
>   after last_writer checks out. This fixes a userspace break
>   where the file was still open for writing after closing it.
> - Fix/unify IMA_UPDATE_XATTR usage
>=20
> Signed-off-by: Janne Karhunen <janne.karhunen@gmail.com>
> Signed-off-by: Konsta Karsisto <konsta.karsisto@gmail.com>
> ---
>  include/linux/ima.h                   |  14 +++
>  security/integrity/ima/Kconfig        |  30 ++++++
>  security/integrity/ima/ima.h          |  13 +++
>  security/integrity/ima/ima_appraise.c |  13 ++-
>  security/integrity/ima/ima_main.c     | 128 +++++++++++++++++++++++++-
>  security/integrity/integrity.h        |  18 ++++
>  6 files changed, 213 insertions(+), 3 deletions(-)
>=20
> diff --git a/include/linux/ima.h b/include/linux/ima.h
> index a20ad398d260..6736844e90d3 100644
> --- a/include/linux/ima.h
> +++ b/include/linux/ima.h
> @@ -93,6 +93,20 @@ static inline void ima_post_path_mknod(struct dentry=
 *dentry)
>  static inline void ima_kexec_cmdline(const void *buf, int size) {}
>  #endif /* CONFIG_IMA */
> =20
> +#if ((defined CONFIG_IMA) && defined(CONFIG_IMA_MEASURE_WRITES))
> +void ima_file_update(struct file *file);
> +void ima_file_delayed_update(struct file *file);
> +#else
> +static inline void ima_file_update(struct file *file)
> +{
> +	return;
> +}
> +static inline void ima_file_delayed_update(struct file *file)
> +{
> +	return;
> +}
> +#endif
> +
>  #ifndef CONFIG_IMA_KEXEC
>  struct kimage;
> =20
> diff --git a/security/integrity/ima/Kconfig b/security/integrity/ima/Kc=
onfig
> index 897bafc59a33..df1cf684a442 100644
> --- a/security/integrity/ima/Kconfig
> +++ b/security/integrity/ima/Kconfig
> @@ -310,3 +310,33 @@ config IMA_APPRAISE_SIGNED_INIT
>  	default n
>  	help
>  	   This option requires user-space init to be signed.
> +
> +config IMA_MEASURE_WRITES
> +	bool "Measure file writes (EXPERIMENTAL)"

"MEASURE" is the wrong term.

> +	depends on IMA

Only IMA_APPRAISE updates the security.ima. =C2=A0This should be "depends
on IMA_APPRAISE".

> +	depends on EVM

Anyone relying on file hashes to verify a file's integrity should
enable EVM, but as much as possible IMA and EVM are defined
independently of each other. =C2=A0Please remove this dependency.

> +	default n
> +	help
> +	   By default IMA measures files only when they close or sync.

By default IMA-appraisal updates the file hash, stored as an xattr,
...
=C2=A0
> +	   Choose this option if you want the integrity measurements on
> +	   the disk to update when the files are still open for writing.
> +
> +config IMA_MEASUREMENT_LATENCY
> +	int
> +	depends on IMA

More specific dependency is required.

I'd like to see smaller patches that build upon each other. =C2=A0For
example, the initial design should be in the first patch. =C2=A0Performan=
ce
improvements, like the latency and latency_ceiling, could be
subsequent patches.

> +	range 0 60000
> +	default 50
> +	help
> +	   This value defines the measurement interval when files are
> +	   being written. Value is in milliseconds.
> +
> +config IMA_MEASUREMENT_LATENCY_CEILING
> +	int
> +	depends on IMA

More specific dependency required.

> +	range 100 60000

The "ceiling" needs to be greater than the "latency". =C2=A0If it isn't
possible to implement in the Kconfig, then at least check in the code.

> +	default 5000
> +	help
> +	   In order to maintain high write performance for large files,
> +	   IMA increases the measurement interval as the file size grows.
> +	   This value defines the ceiling for the measurement delay in
> +	   milliseconds.
> diff --git a/security/integrity/ima/ima.h b/security/integrity/ima/ima.=
h
> index 19769bf5f6ab..195e67631f70 100644
> --- a/security/integrity/ima/ima.h
> +++ b/security/integrity/ima/ima.h
> @@ -160,6 +160,19 @@ void ima_init_template_list(void);
>  int __init ima_init_digests(void);
>  int ima_lsm_policy_change(struct notifier_block *nb, unsigned long eve=
nt,
>  			  void *lsm_data);
> +#if ((defined CONFIG_IMA) && defined(CONFIG_IMA_MEASURE_WRITES))

Both Kconfig options shouldn't be required. =C2=A0Use the more specific
one.

> +void ima_cancel_measurement(struct integrity_iint_cache *iint);

(The function needs to be renamed to something without the word
"measurement".)

Currently ima_cancel_measurement() is defined and called from
ima_main.c.

> +#else
> +static inline void ima_cancel_measurement(struct integrity_iint_cache =
*iint)
> +{
> +	return;
> +}
> +static inline void ima_init_measurement(struct integrity_iint_cache *i=
int,
> +					struct dentry *dentry)
> +{
> +	return;
> +}
> +#endif

If the function definition and usage are in the same file, the
function should be defined as static. =C2=A0There shouldn't be a need for
these the function declarations or stub functions.

> =20
>  /*
>   * used to protect h_table and sha_table
> diff --git a/security/integrity/ima/ima_appraise.c b/security/integrity=
/ima/ima_appraise.c
> index 136ae4e0ee92..6c137fb5289b 100644
> --- a/security/integrity/ima/ima_appraise.c
> +++ b/security/integrity/ima/ima_appraise.c
> @@ -78,6 +78,15 @@ static int ima_fix_xattr(struct dentry *dentry,
>  	return rc;
>  }
> =20
> +#ifdef CONFIG_IMA_MEASURE_WRITES

ifdef's don't belong in C code. =C2=A0Refer to section 21 "Conditional
Compilation" in Documentation/process/coding-style.rst.

> +inline void ima_init_measurement(struct integrity_iint_cache *iint,
> +				 struct dentry *dentry)

(

(The function needs to be renamed to something without the word
"measurement".)

Writing xattrs requires the i_rwsem. =C2=A0Please add a comment indicatin=
g
that callers must take the i_rwsem.

> +{
> +	if (test_bit(IMA_UPDATE_XATTR, &iint->atomic_flags))
> +		ima_fix_xattr(dentry, iint);
> +}
> +#endif
> +
>  /* Return specific func appraised cached result */
>  enum integrity_status ima_get_cache_status(struct integrity_iint_cache=
 *iint,
>  					   enum ima_hooks func)
> @@ -341,8 +350,10 @@ int ima_appraise_measurement(enum ima_hooks func,
>  			iint->flags |=3D IMA_NEW_FILE;
>  		if ((iint->flags & IMA_NEW_FILE) &&
>  		    (!(iint->flags & IMA_DIGSIG_REQUIRED) ||
> -		     (inode->i_size =3D=3D 0)))
> +		    (inode->i_size =3D=3D 0))) {
> +			ima_init_measurement(iint, dentry);

Do we really need to write the file hashes for 0 length files?


>  			status =3D INTEGRITY_PASS;
> +		}
>  		goto out;
>  	}
> =20
> diff --git a/security/integrity/ima/ima_main.c b/security/integrity/ima=
/ima_main.c
> index 79c01516211b..46d28cdb6466 100644
> --- a/security/integrity/ima/ima_main.c
> +++ b/security/integrity/ima/ima_main.c
> @@ -12,7 +12,7 @@
>   *
>   * File: ima_main.c
>   *	implements the IMA hooks: ima_bprm_check, ima_file_mmap,
> - *	and ima_file_check.
> + *	ima_file_delayed_update, ima_file_update and ima_file_check.
>   */
> =20
>  #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> @@ -26,6 +26,8 @@
>  #include <linux/xattr.h>
>  #include <linux/ima.h>
>  #include <linux/iversion.h>
> +#include <linux/workqueue.h>
> +#include <linux/sizes.h>
>  #include <linux/fs.h>
> =20
>  #include "ima.h"
> @@ -42,6 +44,7 @@ static int hash_setup_done;
>  static struct notifier_block ima_lsm_policy_notifier =3D {
>  	.notifier_call =3D ima_lsm_policy_change,
>  };
> +static struct workqueue_struct *ima_update_wq;

All of the workqueue support should probably be defined in a separate
file, not here in ima_main.c.

> =20
>  static int __init hash_setup(char *str)
>  {
> @@ -151,6 +154,7 @@ static void ima_check_last_writer(struct integrity_=
iint_cache *iint,
> =20
>  	if (!(mode & FMODE_WRITE))
>  		return;
> +	ima_cancel_measurement(iint);
> =20
>  	mutex_lock(&iint->mutex);
>  	if (atomic_read(&inode->i_writecount) =3D=3D 1) {
> @@ -420,6 +424,117 @@ int ima_bprm_check(struct linux_binprm *bprm)
>  				   MAY_EXEC, CREDS_CHECK);
>  }
> =20
> +#ifdef CONFIG_IMA_MEASURE_WRITES

ifdef's don't belong in C code.

> +static unsigned long ima_inode_update_delay(struct inode *inode)
> +{
> +	unsigned long blocks, msecs;
> +
> +	blocks =3D i_size_read(inode) / SZ_1M + 1;
> +	msecs =3D blocks * IMA_LATENCY_INCREMENT;
> +	if (msecs > CONFIG_IMA_MEASUREMENT_LATENCY_CEILING)
> +		msecs =3D CONFIG_IMA_MEASUREMENT_LATENCY_CEILING;
> +
> +	return msecs;
> +}
> +
> +static void ima_delayed_update_handler(struct work_struct *work)
> +{
> +	struct ima_work_entry *entry;
> +
> +	entry =3D container_of(work, typeof(*entry), work.work);
> +
> +	ima_file_update(entry->file);
> +	entry->file =3D NULL;
> +	entry->state =3D IMA_WORK_INACTIVE;
> +}
> +
> +void ima_cancel_measurement(struct integrity_iint_cache *iint)
> +{
> +	if (iint->ima_work.state !=3D IMA_WORK_ACTIVE)
> +		return;
> +
> +	cancel_delayed_work_sync(&iint->ima_work.work);
> +	iint->ima_work.state =3D IMA_WORK_CANCELLED;
> +}
> +
> +/**
> + * ima_file_delayed_update
> + * @file: pointer to file structure being updated
> + */
> +void ima_file_delayed_update(struct file *file)
> +{
> +	struct inode *inode =3D file_inode(file);
> +	struct integrity_iint_cache *iint;
> +	unsigned long msecs;
> +	bool creq;
> +
> +	if (!ima_policy_flag || !S_ISREG(inode->i_mode))
> +		return;
> +
> +	iint =3D integrity_iint_find(inode);
> +	if (!iint)
> +		return;
> +
> +	if (!test_bit(IMA_UPDATE_XATTR, &iint->atomic_flags))
> +		return;
> +
> +	mutex_lock(&iint->mutex);
> +	if (iint->ima_work.state =3D=3D IMA_WORK_ACTIVE)
> +		goto out;
> +
> +	msecs =3D ima_inode_update_delay(inode);
> +	iint->ima_work.file =3D file;
> +	iint->ima_work.state =3D IMA_WORK_ACTIVE;
> +	INIT_DELAYED_WORK(&iint->ima_work.work, ima_delayed_update_handler);
> +
> +	creq =3D queue_delayed_work(ima_update_wq,
> +				  &iint->ima_work.work,
> +				  msecs_to_jiffies(msecs));
> +	if (creq =3D=3D false) {
> +		iint->ima_work.file =3D NULL;
> +		iint->ima_work.state =3D IMA_WORK_INACTIVE;
> +	}
> +out:
> +	mutex_unlock(&iint->mutex);
> +}
> +EXPORT_SYMBOL_GPL(ima_file_delayed_update);
> +
> +/**
> + * ima_file_update - update the file measurement
> + * @file: pointer to file structure being updated
> + */
> +void ima_file_update(struct file *file)
> +{
> +	struct inode *inode =3D file_inode(file);
> +	struct integrity_iint_cache *iint;
> +	bool should_measure =3D true;
> +	u64 i_version;
> +
> +	if (!ima_policy_flag || !S_ISREG(inode->i_mode))
> +		return;
> +
> +	iint =3D integrity_iint_find(inode);
> +	if (!iint)
> +		return;
> +
> +	if (!test_bit(IMA_UPDATE_XATTR, &iint->atomic_flags))
> +		return;
> +
> +	mutex_lock(&iint->mutex);
> +	if (IS_I_VERSION(inode)) {
> +		i_version =3D inode_query_iversion(inode);
> +		if (i_version =3D=3D iint->version)
> +			should_measure =3D false;
> +	}
> +	if (should_measure) {
> +		iint->flags &=3D ~IMA_COLLECTED;
> +		ima_update_xattr(iint, file);
> +	}
> +	mutex_unlock(&iint->mutex);
> +}
> +EXPORT_SYMBOL_GPL(ima_file_update);
> +#endif /* CONFIG_IMA_MEASURE_WRITES */
> +
>  /**
>   * ima_path_check - based on policy, collect/store measurement.
>   * @file: pointer to the file to be measured
> @@ -716,9 +831,18 @@ static int __init init_ima(void)
>  	if (error)
>  		pr_warn("Couldn't register LSM notifier, error %d\n", error);
> =20
> -	if (!error)
> +	if (!error) {
>  		ima_update_policy_flag();
> =20
> +		ima_update_wq =3D alloc_workqueue("ima-update-wq",
> +						WQ_MEM_RECLAIM |
> +						WQ_CPU_INTENSIVE,
> +						0);
> +		if (!ima_update_wq) {
> +			pr_err("Failed to allocate write measurement workqueue\n");
> +			error =3D -ENOMEM;
> +		}
> +	}
>  	return error;
>  }
> =20
> diff --git a/security/integrity/integrity.h b/security/integrity/integr=
ity.h
> index d9323d31a3a8..0f80c3d2e079 100644
> --- a/security/integrity/integrity.h
> +++ b/security/integrity/integrity.h
> @@ -64,6 +64,11 @@
>  #define IMA_DIGSIG		3
>  #define IMA_MUST_MEASURE	4
> =20
> +/* delayed measurement job state */
> +#define IMA_WORK_INACTIVE	0
> +#define IMA_WORK_ACTIVE		1
> +#define IMA_WORK_CANCELLED	2
> +
>  enum evm_ima_xattr_type {
>  	IMA_XATTR_DIGEST =3D 0x01,
>  	EVM_XATTR_HMAC,
> @@ -115,6 +120,18 @@ struct signature_v2_hdr {
>  	uint8_t sig[0];		/* signature payload */
>  } __packed;
> =20
> +#if CONFIG_IMA_MEASUREMENT_LATENCY =3D=3D 0
> +#define IMA_LATENCY_INCREMENT	100
> +#else
> +#define IMA_LATENCY_INCREMENT	CONFIG_IMA_MEASUREMENT_LATENCY
> +#endif
> +
> +struct ima_work_entry {
> +	struct delayed_work work;
> +	struct file *file;
> +	uint8_t state;
> +};
> +
=C2=A0
Please add a comment indicating the type of work or maybe update the
struct name.

Mimi

>  /* integrity data associated with an inode */
>  struct integrity_iint_cache {
>  	struct rb_node rb_node;	/* rooted in integrity_iint_tree */
> @@ -131,6 +148,7 @@ struct integrity_iint_cache {
>  	enum integrity_status ima_creds_status:4;
>  	enum integrity_status evm_status:4;
>  	struct ima_digest_data *ima_hash;
> +	struct ima_work_entry ima_work;
>  };
> =20
>  /* rbtree tree calls to lookup, insert, delete


