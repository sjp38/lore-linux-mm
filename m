Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7E8866B025E
	for <linux-mm@kvack.org>; Sat,  7 Oct 2017 09:05:35 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p2so3776341pfk.0
        for <linux-mm@kvack.org>; Sat, 07 Oct 2017 06:05:35 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id n62si3327322pfh.131.2017.10.07.06.05.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Oct 2017 06:05:34 -0700 (PDT)
Date: Sat, 7 Oct 2017 21:05:04 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 3/3] mm: oom: show unreclaimable slab info when
 unreclaimable slabs > user memory
Message-ID: <201710072053.sdlTJ3hP%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="uAKRQypu60I7Lcqm"
Content-Disposition: inline
In-Reply-To: <1507152550-46205-4-git-send-email-yang.s@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: kbuild-all@01.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Yang,

[auto build test ERROR on mmotm/master]
[also build test ERROR on v4.14-rc3 next-20170929]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Yang-Shi/oom-capture-unreclaimable-slab-info-in-oom-message/20171007-173639
base:   git://git.cmpxchg.org/linux-mmotm.git master
config: h8300-h8300h-sim_defconfig (attached as .config)
compiler: h8300-linux-gcc (GCC) 6.2.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=h8300 

All errors (new ones prefixed by >>):

   mm/slab_common.o: In function `dump_unreclaimable_slab':
>> mm/slab_common.c:1298: undefined reference to `get_slabinfo'

vim +1298 mm/slab_common.c

  1272	
  1273	void dump_unreclaimable_slab(void)
  1274	{
  1275		struct kmem_cache *s, *s2;
  1276		struct slabinfo sinfo;
  1277	
  1278		/*
  1279		 * Here acquiring slab_mutex is risky since we don't prefer to get
  1280		 * sleep in oom path. But, without mutex hold, it may introduce a
  1281		 * risk of crash.
  1282		 * Use mutex_trylock to protect the list traverse, dump nothing
  1283		 * without acquiring the mutex.
  1284		 */
  1285		if (!mutex_trylock(&slab_mutex)) {
  1286			pr_warn("excessive unreclaimable slab but cannot dump stats\n");
  1287			return;
  1288		}
  1289	
  1290		pr_info("Unreclaimable slab info:\n");
  1291		pr_info("Name                      Used          Total\n");
  1292	
  1293		list_for_each_entry_safe(s, s2, &slab_caches, list) {
  1294			if (!is_root_cache(s) || (s->flags & SLAB_RECLAIM_ACCOUNT))
  1295				continue;
  1296	
  1297			memset(&sinfo, 0, sizeof(sinfo));
> 1298			get_slabinfo(s, &sinfo);
  1299	
  1300			if (sinfo.num_objs > 0)
  1301				pr_info("%-17s %10luKB %10luKB\n", cache_name(s),
  1302					(sinfo.active_objs * s->size) / 1024,
  1303					(sinfo.num_objs * s->size) / 1024);
  1304		}
  1305		mutex_unlock(&slab_mutex);
  1306	}
  1307	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--uAKRQypu60I7Lcqm
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

H4sICFvN2FkAAy5jb25maWcAjVtbj9s2sH7vrxDS85AAJ8le0jTBwT5QFGWxlkRFpGxvXgTH
6yRGdu2FL23z788MKVuSNXTaoNhdzogih3P5Zjj6/bffA3bYb57m+9Vi/vj4M/i2XC+38/3y
Ifi6elz+XxCpIFcmEJE0b4A5Xa0P/779/uH26ip49+b69s3V66en62C83K6XjwHfrL+uvh3g
+dVm/dvvv3GVx3JUJ8h+9/P4Jy+qOoSfIo8ky9vxcqpFVo9ELkrJa13IPFV83NKPlGQq5Cgx
LSFXtVSFKk2dsWLIz3WVtaPJ57vrq6vToyUuR99dHwciETe/pVKbuxdvH1df3j5tHg6Py93b
/6lylom6FKlgWrx9s7D7fXF8Vpaf6qkqccmw+d+DkZXlY7Bb7g/PrTjCUo1FXqu81llnuTKX
BmQyqVmJL8+kubu9OcmsVFrXXGWFTMXdixcw+5HixmojtAlWu2C92eMLjw+CCFk6EaWWKu89
1yXUrDKKeDhhE1GPRZmLtB59lp3FdinpZ9US+tynt7WsxGtA5qxKTZ0obVDAdy9erjfr5avO
avW9nsiCEw/HCcsjkEnnZZUWqQy7vPY44HiC3eHL7uduv3xqj+OoJnh6OlHTzonASKQyJnNC
qVA3xUTkRh+P26yeltsd9Yrkc13AUyqSvLtO0FugSFh9d619MklJQP9BC3VtZAYnONgpqPRb
M9/9CPawpGC+fgh2+/l+F8wXi81hvV+tv7VrM5KPrUkyzlWVG5mPumsMdVQXpeIC1A84zOBd
Ja8CPdwyzHNfA607F/xZixlIglJU7Zi7j+uz5w3TY42zkELB2bVhaYomkancy5QLEdVajHiI
Jk6yhZVMI3BS+Q0n6XLsfiENDh+PQZVkbO6u/zyOF6XMzbjWLBbnPLcdax6Vqio0+VKeCD4u
FEyDZ29U6VEbsCBdMDgxkqxhmsgavH0VLSWRsntaMOkYzHVinVUZ0cvktSpAMeVnUceqRM2H
HxnLuSDEdc6t4ZczN1PJ6Pp9O+Y0qGfvyEDMnYFTkeAMyi6zHgmTgSKhSwEPmNJCutexpjiO
h6m0nDXW13NzwK7vM009Ys+/3UZY9e0MAkodV571xJURM5IiCuXbgxzlLI3pQ7JL99CsV/PQ
wiK+KDgmFT0eTSRssHmUkk8mspCVpbSndVxJFoooElFXUAW/vno38EINACmW26+b7dN8vVgG
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
7Xc5+DUnkx4X7KIZdTj/D3v+vNGwPwAA

--uAKRQypu60I7Lcqm--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
