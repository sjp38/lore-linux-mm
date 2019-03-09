Return-Path: <SRS0=P3wr=RM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AF52C43381
	for <linux-mm@archiver.kernel.org>; Sat,  9 Mar 2019 18:54:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DD13A2081B
	for <linux-mm@archiver.kernel.org>; Sat,  9 Mar 2019 18:54:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD13A2081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C3938E0003; Sat,  9 Mar 2019 13:54:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 375BF8E0002; Sat,  9 Mar 2019 13:54:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 263858E0003; Sat,  9 Mar 2019 13:54:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id DD12D8E0002
	for <linux-mm@kvack.org>; Sat,  9 Mar 2019 13:54:11 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id o4so1012007pgl.6
        for <linux-mm@kvack.org>; Sat, 09 Mar 2019 10:54:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=0GXV2I+uZyaC56WEwgGEGdqKOxxGEq8sq0jrxKwGDBU=;
        b=OxnyujuZWtG6CiBP0x+0zcoj2LOBwbpfzOgo/aKihpUFgGO/vOYwai3Uf7wiRzfaNL
         h/WAp++xZg/nMEXM1rfCs2QqfmLBDRum1gy5zuJx1tqbWqG6N3t6OVwaYwGX7Dx/rI0K
         2N//bpCqQGoRB8aCFREXrDtQw/DoAuBiaYRzlUVd4eBriuwGDMx+cxujUBV8/N/3zPqM
         9elsgOhIfEUIGH+ciPfRJV/J8vJni4l/VSlnSPO++6T+VmvkLdcvr1hp7VPeoxsctmGz
         9+gntdU3nbJoR8aJwNkLt0P5offj17WUFpDw+/GBW4cwClWZa+j4GhMVlYJ3B3JHMmS5
         epzg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXQie0UO+cRVxH5RDu4vxbBKhTDq/AXSpKKxq4TrMJNfTwPOwvy
	4FzlTzuJBMfwKAvMk3YWevXOJUTQqWyR3pNwWIcrJ/X/JHkgJtaU62sU6DMPBqE4me+0m6Ijjwk
	266FDgXIirBuNmyxXXqftaaKt0UURckdYRo3YVvIGMsb06GD/lC5R43V8/BoUGJKbbQ==
X-Received: by 2002:a63:c64c:: with SMTP id x12mr22726234pgg.285.1552157651454;
        Sat, 09 Mar 2019 10:54:11 -0800 (PST)
X-Google-Smtp-Source: APXvYqytToNEqIW2hd4cLvEF2NkOqhMD/G4bCPHdHJxLvHXI6Yty6QLx0xBp+j71hmGA59jQ+rts
X-Received: by 2002:a63:c64c:: with SMTP id x12mr22726181pgg.285.1552157650182;
        Sat, 09 Mar 2019 10:54:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552157650; cv=none;
        d=google.com; s=arc-20160816;
        b=lCNsHnI/AUXGQRmfraFAw3fadxCfYmmbnO+iBe4odb6CMJQsP9iWcD+UHwx8+F0MCl
         rGBL72N7R+slXN0ZYpCNohL3MNAn91mTodtXHNEefEUMZo1Pt1YZW5DqSOf656ApafUh
         adIX3s/hKsuuR4RZO/w8O6qr09fRj5H1KohQAiTSEA7AKhPHOyGodxKZlK4hU7kyvAbP
         ZvXtJEiXRnPbHHNspW3ay/j898RXFk/pK5JwmfdPJxt2aprJ1tTW72dKzzcN3S6gjPh3
         c4Wlnv5n3FQq4f6ZO/S34CmipVrpPSaWpYK+7oN9Uuv+pwxloe21xPMN+LO1PR3mdbVV
         iUrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=0GXV2I+uZyaC56WEwgGEGdqKOxxGEq8sq0jrxKwGDBU=;
        b=Sl588PUYNVHwv+l9h35fETqP5xGMJRYRD6DIVVsA/VhyTcOZM6NAYQZrELtDhEGJE1
         1sLh5vnsoZOW6/nJ+CctW+QKqQ09YiPAeoYvfOkGjYACJYBOzAjV/6TYwebrS4S2h92w
         M1L3YxabsapNobhh9lMZjCDsiP92xI2w6o9X0fxvdURvAPPcI0efHmLRM7lLcayTdIUo
         lHsQ41FAAT0Ufgb3qKJbXQU7A9jT+INMWlISXB8/NaZZQ57VhhIco/xrqIH0ap9caw5f
         z07WywXrVMsYQJfIlbwFO/9oh4rJWE7in6Z5tH8PMvIB+O2TuOkKKKGmXAlYSPAfi9QY
         5CwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id f1si909915pfn.10.2019.03.09.10.54.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Mar 2019 10:54:10 -0800 (PST)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Mar 2019 10:54:09 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,460,1544515200"; 
   d="gz'50?scan'50,208,50";a="281239318"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by orsmga004.jf.intel.com with ESMTP; 09 Mar 2019 10:54:07 -0800
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1h2h6k-0002ni-3J; Sun, 10 Mar 2019 02:54:06 +0800
Date: Sun, 10 Mar 2019 02:53:57 +0800
From: kbuild test robot <lkp@intel.com>
To: Andrea Righi <andrea.righi@canonical.com>
Cc: kbuild-all@01.org, Josef Bacik <josef@toxicpanda.com>,
	Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>,
	Paolo Valente <paolo.valente@linaro.org>,
	Johannes Weiner <hannes@cmpxchg.org>, Jens Axboe <axboe@kernel.dk>,
	Vivek Goyal <vgoyal@redhat.com>, Dennis Zhou <dennis@kernel.org>,
	cgroups@vger.kernel.org, linux-block@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3] blkcg: prevent priority inversion problem during
 sync()
Message-ID: <201903100216.OQdFKZhP%lkp@intel.com>
References: <20190308212806.GA1172@xps-13>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="envbJBWh7q8WU6mo"
Content-Disposition: inline
In-Reply-To: <20190308212806.GA1172@xps-13>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--envbJBWh7q8WU6mo
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Andrea,

Thank you for the patch! Yet something to improve:

[auto build test ERROR on linus/master]
[also build test ERROR on v5.0 next-20190306]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Andrea-Righi/blkcg-prevent-priority-inversion-problem-during-sync/20190310-020543
config: riscv-tinyconfig (attached as .config)
compiler: riscv64-linux-gcc (GCC) 8.2.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        GCC_VERSION=8.2.0 make.cross ARCH=riscv 

All errors (new ones prefixed by >>):

   fs/sync.c: In function 'sync_fs_one_sb':
>> fs/sync.c:83:3: error: implicit declaration of function 'blkcg_start_wb_wait_on_bdi' [-Werror=implicit-function-declaration]
      blkcg_start_wb_wait_on_bdi(bdi);
      ^~~~~~~~~~~~~~~~~~~~~~~~~~
>> fs/sync.c:85:3: error: implicit declaration of function 'blkcg_stop_wb_wait_on_bdi' [-Werror=implicit-function-declaration]
      blkcg_stop_wb_wait_on_bdi(bdi);
      ^~~~~~~~~~~~~~~~~~~~~~~~~
   cc1: some warnings being treated as errors

vim +/blkcg_start_wb_wait_on_bdi +83 fs/sync.c

    77	
    78	static void sync_fs_one_sb(struct super_block *sb, void *arg)
    79	{
    80		struct backing_dev_info *bdi = sb->s_bdi;
    81	
    82		if (!sb_rdonly(sb) && sb->s_op->sync_fs) {
  > 83			blkcg_start_wb_wait_on_bdi(bdi);
    84			sb->s_op->sync_fs(sb, *(int *)arg);
  > 85			blkcg_stop_wb_wait_on_bdi(bdi);
    86		}
    87	}
    88	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--envbJBWh7q8WU6mo
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

H4sICN8JhFwAAy5jb25maWcAjTvbctu4ku/zFaxM1VZSJ/E4tuOT2S0/QCAoYkQQNABKdl5Y
ikQ7qliX1WUm/vttgJJ4a/hsaiax0Y1bo+/d/P233wNy2K+X0/1iNn15eQ2ey1W5ne7LefC0
eCn/JwhlkEoTsJCbC0BOFqvDrz+2i93s7+DLxeXFZTAqt6vyJaDr1dPi+QBTF+vVb7//Bv/9
DoPLDayy/e/Azbi9+fRi5396ns2C90NKPwRfL64uLgGXyjTiw4LSgusCIHevpyH4pRgzpblM
775eXl1ennETkg7PoMvGEjHRBdGiGEoj64VMrBgJC55GEv4qDNEjALpzDt2lX4JduT9s6tMM
lByxtJBpoUVWL8RTbgqWjguihkXCBTd311f2tscDSJHxhBWGaRMsdsFqvbcLn2YnkpLkdOp3
7+p5TUBBciORyYOcJ2GhSWLs1ONgyCKSJ6aIpTYpEezu3fvVelV+aKytH/WYZ7S5Yn1eJbUu
BBNSPRbEGEJjFC/XLOED5FAxGTOgBY3h1MAmsBdcJDnRlqv7YHf4vnvd7ctlTdshS5ni8Nzq
vtCxnDTICyOhFISn9ZjOiNLMghqM0VhBwP05HCQNE6b6KBRoO2Jjlhp9OpZZLMvtDjtZ/K3I
YJYMueXC8/VTaSEcNkCp48AoJObDuFBMF4YLeF2EgJliTGQG1khZc8vT+FgmeWqIekTXP2I1
YZXwZfkfZrr7GezhqsF0NQ92++l+F0xns/VhtV+snus7G05HBUwoCKUS9uLpsHUQzXvLK5oH
uk89mPpYAKw5HX4t2AMQFZMHXSE3p+vOfD6qfkBmn15Y05iF1TvXizme1HmWSWU0iK35fPW1
uS4dKplnGpeKmNFRJmGSfTsjFf7s1b5WWt1aKI5iCcGfbpCMQHrHTqOoED8HLWQGnMO/sSKS
yrIm/CNIShlCji62hh8aUgSSaRJ4CsoACbSMUYQ24NUbNSnk5AoEX+GXHzIjQI0WR5HHkR51
pN/EiCq5xZlbav6ASE6D++GJRjh18yE+TkCVRLnvNLlhDyiEZdJ3Rz5MSRLhL+gO74E5neSB
6Rh0MgohXOLj4ZjD1Y60xukFaw6IUtzzpCM78VHgcwdZ9OZDWkZxpqh9o9NdxYCFIQtrfnOG
wzJ0cdbN9bvSz5c3PaVzdDaycvu03i6nq1kZsL/LFWg1AvqNWr0GWr1Sf8d16uXRM49FBS2c
3vNxmbXpxIBDgHOaTsjAA8gxi6kTOWhe1s6Hl1FDdjLmHl6XEU9ANyNL3t4MuKlJq7im4/pX
IRo69huYmSIU5PqqHssI7C2jSDNzd/nryf0pL09/zucG52DklMZJrTY0txsGYxwlZKj7cDXR
TNT6OuNpW1mfbTUBL0MRY0kBehNB0Lnoj8YTBna2sV8EeoMRlTzC75brG3cdGjIABy2Bh0/0
3XXFWtnLdG+ZKti/bsomBzkrosbXVxwh+xF4e8NbhkVIODzsGiZygqnpM5ykjy19Sx6y+FHD
cYurIcY5DQQwZsM2F4kMmWFyeO0jlVpG2XIIeNukoMisGkqak6Is98nkUzndH7ZlS/jAYfp8
eYm5jN+Kqy+XzZVh5LqN2lkFX+YOlqmOMVgDbL2x4ceuEVCIEASGWW+5euX1P+U2AM0xfS6X
oDgaM2oxE707ngKE6Xb2Y7EvZ/amn+blplzN24s0NZsTyQLYeZhaH4FSpnVH+Tn2cZITSznq
AEFEQfGAMzbMZa77LA/v7fzRY2TTmU2TxnrHoMjJL2gRwyh4NCd/szlrzJXpOIJ2v8ZKidUe
A1hnQlTYUtmKRW5Oz7ZWJKRy/On7dAeR5c+KYzbbNcSYLT80S/IhxGY2koEY8N3zv/51jnKc
1dbCRhafGwIjwzxhHnNlFQzCNaB5gCWcCipyp4XagcUR7qLFvKOl+jB07kRxUGCeyU3gcbaj
EPtVzg776feX0sXegTNx+xZrDiB6FRB8JhF+4wqsqeIZbkKOGALE22PoFAvztiJxBxDlcr19
DQQmOSflkBDTUrR2AJgsZFb/gurKOsxmfRFHhAqnCddZArKTGQcGftR3Nx1rTK0HiwVToB7B
EwpVYc5GsXZvtECmnAJoAUcA0qRu+t3N5Z+3J4yUgQSDK+FEYyRauj5h4IxD0Iw7sFQQdPxb
JiXuRX0b5LhD+M1xv8QfDg5nzwYS7nF0hnlWDFhKY0EUJhVOFVklkRkrG4xykrTiX4ZFb+4d
mXUM/3KUdrwSln8vwDMLt4u/K2+s5e/RlqmEX/H7UEraIVGtiBez49qB7GvvvHLnYpZkHh8X
Ii4jsggnExAwDYlVcr5g2y0fcSVAAbIqI9M7ZrTYLv+ZbsvgZT2dl9vm+aJJkUgSes5mH3ji
YkJMEhtXgOCmCBUfe+/oENhYeZRjhWBzVMdlQKcJOcaCyrPjBfwFK3KwY6eXHhx2wdy9dusN
hqn2RB8GiwxC08j3yajJHjICRcmNJ5cGUKtjjGKsuUDl9+EgK9otOwxjlQ5u7gmEUL6gPSPK
era9N0/HggX6sNmst/tTAlQsdjOMQPCw4tHui0eFKVhZnQN3QUDl6I2zqiJ4fJiNM5Jyj4K/
Qg/PGLgFItidj18fxkGKP6/pw21vmil/TXcBX+3228PSxWG7H8D282C/na52dqkADHwZzIEO
i4398UQZ8gKR2jSIsiEBa3eUlvn6n5WVmGC5nh/AAr7flv97WIBTGfAr+uE0lUOQ9xIIuOB/
BdvyxSWrd2261yiWQytlcYJpyiNkeCyz9mgdIkrQnLnuXb7eJF7v9p3laiCdbufYEbz4a3CM
gF92622g93C7ptF9T6UWHxqq9Xz2/rkZjWXv0JpqfuTIBtFOHAVA61Kdc7erzWHfx64Tc2mW
93kphgu75+R/yMBOabG+trlV3EIRwVDmpMBT0xnwCyZKxuBiCprKlz8B0MgHs8cjidPAnTev
b52Jc64ZD1gmhQKwxHcwFP7PcNgDT5JHlNeuKPoAV7iU82t8HHxez7jAAbH2mOesf8bMZMHs
ZT372ZVGtnJOLXhmtoBgM9HgTEykGllnzeXHwOqKzCY29mtYrwz2P8pgOp8vrHWHsMuturto
BWk8pUbhHtQw47JTqjjDJp89ecYJmEAy9iQZHRTsBvMkZhzcpjwSnBnjiWg7qzU3xEyBW4ef
lRgahxJL92g9sLlRzQdJq2QA41jZCLxQFH3QcU8ro3V42S+eDquZpf5J+udnjVMb8wiiWvD4
E7C07IF62L3GihMa4mxpcYT1iXBf2YJjfntz9Rlic49diw0Fy6w5vfYuMWIiS3DX2h3A3F7/
+W8vWIsvlzjvkMHDl8tL57D5Zz9q6uEACza8IOL6+stDYTQlb1DJ3IuHr7coWLFhDh6PxHWS
YCEnp6xc363eTjc/FrMdpmNC5dGiShRhVlBGe8sRmFKr6mqIZsF7cpgv1mDgspOB+4DXjYkI
g2TxfTuFiHO7PuzBbzgvFG2nyzL4fnh6AnsQ9u1BhMu9zVgkNkNYABdidKhFSOYp5qXmIHIy
pryAyNQkEPWkQNFGZsTCe1lPO3iOrGIaNoUvb8uqu4Qdc27TvG3h7Xj243Vnq/RBMn21trAv
kSl4KnbHB8r42JOiH4CdDYceRWYeM4Yzn52oJFxbT7jxVogHRZ5k3Gs58wn+OEJ4OJ4JbUuT
KDBlEEmxEN+pyrbxAYfHwlWyMrYuTDyBSmjVUc/1rqJbQQZ5hCUO9WNKITL0lLJI/hBynfnC
itzjFbmMXBWieSoYgMAl0Crt52bFYrZd79ZP+yB+3ZTbT+Pg+VCCr4qIOZjgIV5aoMnIukOJ
lKO8m8IBmI2JISZqhFlgCsDcHTOQp0aQJdgS6rwDJ8H/rLc/m9vbhWId4k8dT071gr5v6JbU
68O2ZaRO/Gxrb1VI2RqBkGbQMoSgsY4gnX1tF55O/OIy4g6nnbHnyUDiBUMOdMi9OleVy/W+
tL4+Jso2Gjc29OprV7VZ7p7ROZnQJ37wq7YJb9upKiyAfd5rV8sPJDzUj8XmQ7DblLPF0znb
Uuvy5cv6GYb1mnb11GAL4dtsvcRg6UP2R7Qtyx3osDK4X2/5PYa2uBAP2Pj9YfoCK3eXblyO
wvP0bvZgU8y/fJMebD3toRjTHCVYJmwkECnmCdQfjNequ34anC08r5NN+oUHmyKYwWP0YzWA
0Jg35NGy8JBTWyIqUtVMkmsecZt5Szy+E8/AOHqVtnN7XSEC9L8v5IlEn0/BuW91iNT++TGh
ZBFQW01FMZIpsQblyotlYwfwlVhKGfgh/w+UN9aJdFJw8KzEfdcqt9CyB1JcfU2FDYs8adgm
lj2+F0uQLIttLUWE4vbWU/pygQUl+O0ExU+qSN9okdV8u17MW3XNNFSS4/5wSHCNlnZj6irg
n9h8z2yxesYNC+4/8tRAUGBwV8LlhVCAJyDV3KOEdcKFN5K3FX/4OWW0r58jW4OpmLelMtiD
VeeRrupLhfQ0EFk/wPb0jTpGtXETm+hTj1m3kFG/QioNjzxKpIIV3uaciLwx+z6XBqevbWWK
9E3hSY9XYB80ym1nDQ47plQ74Iqw09mPjhOvexWVSqXsysN87cpjyMtYa+nb3sFAYSahYji1
XaMSnjN1//ivbatp7r1hCcM8zTNp0r+4LmeH7WL/ijmTI/boSfsymivwasFHZdqpZwPK1BPL
HHH9xQ5wrx0P2Y6Efs3kiJdocffudbqcfrTZ2c1i9XE3fSoBYTH/uFjty2d7iY+70nX3ftwt
p7OfH/fr5fp1/XG62Uy3y/W20YzqeL6fmUQCvpM94MaWXZRu+JiKWLFxJaqOVQFypDQDRrNp
a3s1HCVhqQeaQYwHrpsrRzYODexDIfLDOUTRz3hUbueZz5chxyu2FsxNXmDVDYC5Fp0m8vUV
vGkSeeohRwSw82zw+BWZWkFufEexKERNiPHUMh0GvIYPeutd2QvAEy4JH7jNfB3L9KvH8tms
q4dGtc/3DZw6rOnFxujw8M0SdjVkFX63fq1tjFgPuAqx7diwNWQrV6zpmdHYwTpl6WYgdWK+
qukjZqClGigQdEuTtLp9qFShxwmBXXCboe6Lbg9jTfAobJXKrVZJhyglm20/P0DWqxYON7rZ
gj746XK882UJYUq/I0emWjrTOHQNWKfq+92/vRj3OWfm7ubcAwWRvW1X661w0/rq4JPrewbL
Mvu5cweaHb9GwLRtVQ613wbgjn7qOsZErk3VGYyQMFJEsGJCVHp3dXnztU3JzH2Q4O2stP0k
bgeicWcpT0FX2TSiGEhPZ2d1hbamP3EYs8lVXR29+cjVHLASrh0Y7JggvuROF8ndtJBpO+Pd
5PgJsYVyRxXXSA0naPWSNSFv3UgqcN8njIxOHRi4ESY2+AEL3C6qtpYaMZWy85cJx5aWsPx+
eH6ueLh2FyyDQXjHUu31ztySFvGNrgzXVjlJPRd0YKCAlqnPS6x2kYO/gPxvvbtr7QKDBiu+
gTX2FcQs8PgJiG1Gx2xL1UI2IpqkjX7Ck7fiht0hIPJsTwEIleNjg2hGEf6LO5XwYxcJvEuQ
rGc/D5tKgOPp6rkT8keuQyjPYKWqqc1zPwss4hwUmv3uB0Wa3KMFl8ZjpcBgIAGy4/Jj8GJM
kpzVXyVVQJs9krmB4foK7gOC6vVYGva1S4dWdokRY1mHXyoPyqbCzuwcvN+Bp+YqZx+D5WFf
/irhh3I/u7i4+NDXfViGrcsgtjX+zX4SYqSwUpjACd9AO4ZFBcn42cDgy7oQC57V2G4Ir0Wf
TKqzvW336+5lfBGrz0CUQddqMObwKm8UcY/6pJLLt27KPYc5ag/+nzD0W2rBRXjclxiucKiC
u6SGEyT+sN/woOrPfrHjOue9xLQY//FdHJKX4O6zoHtdnfONG4BgVjZA+bX/iRIFU0oq0GF/
sV6DYCM0tt1+KE7TJYvylNafyaiOw3aGDhXJYhwnfEyJlYeo86ENAiwm3NjPxIbdFuEjWFSt
tYpZv6+DcvwmozqDM6iNReygc+TOpamaDv63cd4qcKf/bZTtDhbV49v1u/WHZibUyyDOtqVF
SIz1epXK/ckQTUTm6/TNB2BjkGd041UHtqj86f8DGbiSUPE6AAA=

--envbJBWh7q8WU6mo--

