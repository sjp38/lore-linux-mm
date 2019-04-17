Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15EF0C10F12
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 06:45:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D7F82176F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 06:45:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D7F82176F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA80C6B0003; Wed, 17 Apr 2019 02:45:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B55EE6B0006; Wed, 17 Apr 2019 02:45:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A6CA76B0007; Wed, 17 Apr 2019 02:45:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 685166B0003
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 02:45:22 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id m35so14088745pgl.6
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 23:45:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=yuPRsWWbcf7x3IEVMBfnYtER77WRpDl5GlI0+K4xatc=;
        b=T3wjfvVAj+f67jsLZSgWhb6YU3sOSe8ymc6uZvkyxqDwNlhViq0EFQNPAaultLHjnt
         S7NlOlISOp6Lw7QFySeWjG84vPe7UCbFiyhxvON8uYB/HKQUo6rc0Ed5eWRpJJcj/92m
         zI9anebBiIegyxOFNFXGD8cJXBqIP34WcZxLQFf0x41oZ1wEVyWiKE63Hy8k17eH6Rn1
         o+UXiOtFV3gGYIMsy0r13bW2dm7my6fLEXL1jleHKFJMJivAgQe3kquCSHs2YTLw2kys
         5ugUS0EXMA3CG4ANgEFoGL3S4eofoOHIgST21+yQxYpwt+xLZSNA3gCEiBxKCcIMGmDQ
         /XyQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUF0GbgQXd5OAMyBtS8tHsRkoDrhFT0cJLQtVhxPgzMgZFWnMza
	OC/fiZ18pfLlGkrkMYHZsoZ4Rd5ejQjd7Z3Q7vuWGBcKv2lFVDqclwrcYrH20ux8QO60ifi9ndW
	RcmpJZHbZxAqIMvlUo7DGfGNKXs/TVJJTVEWaYdMLjkPiGnjXyyZdiAJ4eh/dXUqg2g==
X-Received: by 2002:a17:902:8f92:: with SMTP id z18mr89113805plo.123.1555483521834;
        Tue, 16 Apr 2019 23:45:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxVF4VPYXhlvDcmegtPdQ4LuO7xcysyFaq/WlsuAeoDZmZvw30ZM9+AKDProEYU+2uADw49
X-Received: by 2002:a17:902:8f92:: with SMTP id z18mr89113709plo.123.1555483520496;
        Tue, 16 Apr 2019 23:45:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555483520; cv=none;
        d=google.com; s=arc-20160816;
        b=idswUViMLIpI5SyiOEFJJK0XwEKcVdIxYvp2AoaOkVgmGQVCMytUdX2++v9oiNoYgu
         NEOc2huYCdA8T2uF+88ToyBYlqS5tYsyS9CkvJXMAv66+LtSolzdQd+klIHiaoZZ3MTK
         bmHaW1yglBRd0lWza5YWSbP9rO24zH4Fh9110OQXtbGh1QWc4ZgHEz+B+fmUOWv24nv8
         Wn6Ixd7kRLh4lAntT5ONF/2qu6DVVyWdzZoW7EPHMVbFvn6OaC74C+wWPbOwLZ7LCsi8
         6+LkQXFIJu/jn0SZ0fFhJj1G4HlQeO+haBfMipxKKOG5Ga15EIOAK+XkhFFXAPtRPgfj
         d7mw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=yuPRsWWbcf7x3IEVMBfnYtER77WRpDl5GlI0+K4xatc=;
        b=LhwoUYttsdvjsRAFGKBCXmiVRzjZC24ry+ahqeqRShv148bRQYZYBEq9BDn06hjaDH
         DoohzTk0JUnLVO4izvzy32xpSgBsgVN/mCnpCfR1TbNKZzQlUCmJDejCK7AgquXnDeZx
         I91uLOTgu1mABheolRsYSucUhOMW/cF4OBIqViZgNkVtaj8K30AYHrs7wEtUxyoIcg0r
         8Mmn+hUdPPWhAPWMMbyWwZY1/S/BVB3IBDk5KPhJrDl7WXDbu1255xbvBuSqOjdwYHTb
         itK2ZkVKMhAvX37/TQaXCLKyE6wNBaClQ9F7zjTJYiVLeAwOf7lf21sL2fW+3PrLJs1i
         MdQg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id m13si49933121pga.331.2019.04.16.23.45.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 23:45:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 16 Apr 2019 23:45:19 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,360,1549958400"; 
   d="gz'50?scan'50,208,50";a="162607140"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by fmsmga004.fm.intel.com with ESMTP; 16 Apr 2019 23:45:18 -0700
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1hGeJp-00070M-FZ; Wed, 17 Apr 2019 14:45:17 +0800
Date: Wed, 17 Apr 2019 14:44:23 +0800
From: kbuild test robot <lkp@intel.com>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: [mmotm:master 18/317] mm/vmscan.c:2966:14: error: implicit
 declaration of function 'lruvec_page_state_local'; did you mean
 'lruvec_page_state'?
Message-ID: <201904171421.wplvKXWT%lkp@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="LQksG6bCIzRHxTLp"
Content-Disposition: inline
X-Patchwork-Hint: ignore
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   def6be39d5629b938faba788330db817d19a04da
commit: 7e0f45f540683e6312df0cfbcf0c703f35fcf763 [18/317] mm: fix inactive list balancing between NUMA nodes and cgroups
config: riscv-tinyconfig (attached as .config)
compiler: riscv64-linux-gcc (GCC) 8.1.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout 7e0f45f540683e6312df0cfbcf0c703f35fcf763
        # save the attached .config to linux build tree
        GCC_VERSION=8.1.0 make.cross ARCH=riscv 

Note: the mmotm/master HEAD def6be39d5629b938faba788330db817d19a04da builds fine.
      It only hurts bisectibility.

All errors (new ones prefixed by >>):

   mm/vmscan.c: In function 'snapshot_refaults':
>> mm/vmscan.c:2966:14: error: implicit declaration of function 'lruvec_page_state_local'; did you mean 'lruvec_page_state'? [-Werror=implicit-function-declaration]
      refaults = lruvec_page_state_local(lruvec, WORKINGSET_ACTIVATE);
                 ^~~~~~~~~~~~~~~~~~~~~~~
                 lruvec_page_state
   cc1: some warnings being treated as errors

vim +2966 mm/vmscan.c

  2955	
  2956	static void snapshot_refaults(struct mem_cgroup *root_memcg, pg_data_t *pgdat)
  2957	{
  2958		struct mem_cgroup *memcg;
  2959	
  2960		memcg = mem_cgroup_iter(root_memcg, NULL, NULL);
  2961		do {
  2962			unsigned long refaults;
  2963			struct lruvec *lruvec;
  2964	
  2965			lruvec = mem_cgroup_lruvec(pgdat, memcg);
> 2966			refaults = lruvec_page_state_local(lruvec, WORKINGSET_ACTIVATE);
  2967			lruvec->refaults = refaults;
  2968		} while ((memcg = mem_cgroup_iter(root_memcg, memcg, NULL)));
  2969	}
  2970	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--LQksG6bCIzRHxTLp
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

H4sICIDJtlwAAy5jb25maWcAjTvbcts4su/zFaxM1VZSO8k4tuP1nC0/QCAoYkQQNABKcl5Y
ikQ7qliSV5eZ+O9PNyiJN8C7qZnEZjeaQN+70fz1l18DcthvVrP9cj57fn4Nnsp1uZ3ty0Xw
uHwu/x2EMkilCVjIzSdATpbrw8/ft8vd/K/gy6fPny4+budfglG5XZfPAd2sH5dPB1i+3Kx/
+fUX+O9XeLh6AUrb/wvsqpvrj89I4+PTfB68H1L6IbhFOoBLZRrxYUFpwXUBkLvX0yP4pRgz
pblM724vPl9cnHETkg7PoIsGiZjogmhRDKWRNaEjYEJUWgjyMGBFnvKUG04S/pWFLcSQazJI
2P+AbGLFSFjwNJLwV2GIHgHQnn5o2fkc7Mr94aU+40DJEUsLmRZaZDUhpF6wdFwQNSwSLri5
u7pEHh43JUXGYUeGaRMsd8F6s0fCp9WJpCQ58eLdu3pdE1CQ3EjH4kHOk7DQJDG49PgwZBHJ
E1PEUpuUCHb37v16sy4/NGjrBz3mGW1SrPerpNaFYEKqh4IYQ2jsxMs1S/jAsamYjBnwgsaw
a1BAeBccJDnxlqv7YHf4tnvd7ctVzdshS5nioETqvtCxnDTYC09CKQhP62c6I0ozBDXUrUFB
wPk5bCQNE6b6KBR4O2Jjlhp92pZZrsrtzrWz+GuRwSoZctTt8/FTiRAOL3Byx4KdkJgP40Ix
XRguQLoOBmaKMZEZoJGy5itPz8cyyVND1IOT/hGrCatMOst/N7Pdj2APRw1m60Ww28/2u2A2
n28O6/1y/VSf2XA6KmBBQSiV8C6eDlsb0bxHXtE80H3uwdKHAmDN5fBrwabAVJc96Aq5uVx3
1vNR9YNj9UnCmsYsrORcE7M6qfMsk8poMFvz+fK2SZcOlcwz7baKmNFRJmERys5I5RZ79V60
VkvLiaNYQtyiGyQjsN6x9SgqdO+DFjIDzQFfVkRSoWrCP4KklDnY0cXW8EPDisAyTQKioAyQ
wMsYRWgDXsmoySFrV2D4yn34ITMC3GhxNHk30oOO9JsYUWW3buWWmk8dltPQfhDRyM3dfOh+
TsCVRLlvN7lhUyeEZdJ3Rj5MSRK5JWg374FZn+SB6Rh8shNCuHQ+57LIgR3uU5NwzOHcR0G4
mQkvHBCluEfeI1z4INxrB1n0ppRRi2ycah/3xAgxYGHYDNc2qqC2F2fHXQudfr647nmkY36T
ldvHzXY1W8/LgP1VrsHlEXB+FJ0euPzKNx7p1OSdex6LClpYp+hTQQz4xEC24FZDnZCBB5C7
wqlO5KB5WFwPklFDdor0HkOQEU860j/Cbq4H3NSsVVzTcf2rEA0H/BViUBEKcnVZP8sIvFtG
kWbm7uLno/1TXpz+nPcNmcPIepSTz224dfsYInWUkKHuw9VEM1E784ynbU9+DuSQ1A0UMcgK
cKoOBJ2L/tN4wiAIN94XgVNhRCUP8DtqfeOsQ2PzyQQEn+i7q0q1sufZHpUq2L++lE0NsiFG
ja8uuYPtR+DNNW9FHSFh8/DWMJETlw8/w0n60HLGZJrFDxq2W1wOXZrTQIBIN2xrkcgcK0wO
0j5yqRWxUUMgwScFdayqoaS5KMpyn00+lrP9YVu2jA+yKagRXPnk1+Lyy0WTMjy5aqN2qLjJ
3AGZahuDDcA2L1jx7Bo1jAjBYBim0pWUN3+X2wA8x+ypXIHjaKyozUz0zniqHmbb+fflvpzj
ST8uypdyvWgTaXo2a5IFqPMwxQSCUqZ1x/lZ9bGWE0s56gDBRMHxQKY2zGWu+yoP8rbJ6rHs
6aymSYPesdyy9gtexDAK6c4pGW2uGnNlOlkivq9BKUHvMQA6UI6FLZetWGTX9AJvxUIqxx+/
zXZQ0P6oNOZlu4HStpWkZkk+hMINyxwoO989/fOf5xLIhnQtsOz43DAYGeYJ84QrdDAOrQHP
AyphXRAUkojUrjqOcFtK5h0v1Yc5104UN8y3uAk8rrYcYj/L+WE/+/Zc2pI/sCFu31LNAZS2
AirTJHKfuAJrqnjmDiFHDAHm7Ql0ioV525HYDYhytdm+BsJlOSfnkBDTcrT4AJQsZOh/wXVl
HWXDXMQyocJpwnWWgO1kxoJBH/XddScaU0xvXZUWuEfIhEJVmHNQrNMbLRxLTtW1gC0Aa1K7
/O764o+bE0bKwIIhlbCmMRItX58wyNShonZnt1QQ5/OvmZTuLOrrIHdni1+t9ku34GBzuDew
cE+iM8yzYsBSGguiXFZhXRE6icygbTDKSdIqjpmrtLNyZJgY/mk5bXUlLP9aQmYWbpd/VdlY
K9+jrVAJv7rPQylp10u1I17Oj7QD2ffeeZXOxSzJPDkulGNGZJGbTcDANCTo5HyVuCUfcSXA
AbKqXdPbZrTcrv6ebcvgeTNblNvm/qJJkUgSevaGAp7YgtFliY0jQOVThIqPvWe0CGysPM6x
QsAG1pEM+DQhx66K85x4gX4BRQ5x7CTpwWEXLKy0WzIYptpTfRhXZRCaRotRRk31kBH2+oyn
0QZQ9DFGMdYkUOV9bhCadisOw7OWB4ffAYGpMVh85c2amwEOKV+pnxGFKW9PGdKxYIE+vLxs
tvtTM1Ysd3MX50Di4gE35K4lUwi/Oge1ww2iINw6rIi7qszGGUm5x/NfOjfPGOQLItidt19v
xkKKP67o9Ka3zJQ/Z7uAr3f77WFlC7Tdd7CHRbDfztY7JBVA5C+DBfBh+YI/njhDnqGEmwVR
NiQQBo9mtNj8vUZTClabxQFC4/tt+Z/DErLNgF/SD6elHKq/50DAAf8RbMtn2zzftfleo6Dq
Vl7kBNOUR47HY5m1n9a1owSXmuve4euXxJvdvkOuBtLZduHaghd/AxkT6Mtusw30Hk7XjMbv
qdTiQ8Pnnvfe3zejsextWlPNjxrZYNpJowCIuda547t+Oez72HWbIs3yvi7FcGArTv67DHBJ
S/U1dmTdoYsI5lROCjo1m4O+uEzJGLeZggvzdV0ANPLBcHsksa65I/P61Jk4d6jdlcykUACW
7jcYCv9nbtiUJ8mDU9cuqVMAl24r51fu55AMe54LNyDWnrid9feYmSyYP2/mP7rWyNY224WU
Da8dsH8NWcZEqhFmcbarBuFYZNjx2G+AXhnsv5fBbLFYYtiHesxS3X1qVW88pUa5U6thxmXn
guMMm3z2dCcnEBvJ2NOatFCMF56OjYVjLyRxK2M8Ee0sttaGmCnI99x7JYbGoXT1gbQeYEdV
80HSumiA567LJkhPneiDTt5aBa3D8375eFjPkfsn61+cPU4d5SMod6EUSCAEsyn1qHuNFSc0
dKsl4ghMltxJNIJjfnN9+RmKdk9ciw2FyKw5vfKSGDGRJe6c227A3Fz98S8vWIsvF27dIYPp
l4sLm8n5Vz9o6tEABBteEHF19WVaGE3JG1wy92J6e+MEKzbMIRWSbp8kWMjJqV3Xz7e3s5fv
y/nO5WNC5fGiShRhVlBGe+QILKlddfWIZsF7clgsNxDgslOA++C+wyYiDJLlt+0MStHt5rCH
vOFMKNrOVmXw7fD4CPEg7MeDyG332MpIsHVYgBa6+FCbkMxTV/qag8nJmPICSlaTQDmUAkcb
LROE99qh+PBccsU0bBpf3rZVewh8ZtOmRTvC4/Ps++sOpwaCZPaKsbBvkSlkKvjGKWV87Ond
DyDOhkOPIzMPGXMrHy5UEo6tJ9x475UHRZ5k3Bs584lbOEJ4NJ4JjReaTmDKoMRioftNVRuO
DzgIy+2SlcHbZOKpYEJ0R73Uuyp7BRnkkaujqB9SCiWj5wKM5NOQ68xXVuSerMi26qrazXO1
AQhcAq/SftNWLOfbzW7zuA/i15dy+3EcPB1KyFUdZg4heOi+c6DJCNOhRMpR3u3tAAyLZaiJ
GvUXhAIId8fW5GkoZQWxhNrswFrw35vtj+brkVCsQ7eoa4LY78eKTXi4FU9OVw79LNK+XG8O
21Y4O2k+3u1VVWnrCRQ/g1bIBN92BOnstn13ddIs21S3OO2mP08G0n0hyeGAudc7q3K12ZdY
FbiMHgt6g0Va3w+rl9XuybkmE/qkOX4nOOHtiFYVEPCe99rOCgQSRPp9+fIh2L2U8+XjuWFT
e/3V8+YJHusN7Xq0wRYKvflm5YKl0+z3aFuWO/B2ZXC/2fJ7F9ryk5i6nt8fZs9AuUu6cTgK
4umdbIpd6p++RVO8kpsWY5o7GZYJrBkixTwl/dR447+d13GrhUc62aR/d4HNhDkIo1/VAYTG
vGG5qMJDTvGWqUhVs8+uecSxeZd4siyeQRj1unebINu7DIgUvuIoEn09hTKgNYFSZ/LHnhQi
OKM6FcVIpgRDz6UXC6sMyKpYShlkLP8Dyht0Ip0UHHIwcd+N3y20bEqKy9tUYAHl6eQ2sXD7
XixBsizG6xgRipsbz+2ZLUEocZ9OUPdOFemHN7JebDfLRetqNA2V5O7MOSRuj5Z2q++qNTDB
ztB8uX5yhyB3pslTA+WDcScdtoPkBHhKV809TlgnXHhrfhwagJ9TRvv+OcJrnEp5Wy5jTBIe
4hV3pAs79ua2CDZFrw841S2J9MwxYWKBo4Uj31wIUAD9VQ9Z98qkFlYqDY88vqaCFd4ZoYi8
sfo+l8YtBpyoivR14WnEV2AfNMpxwMcNO/ZoO+CK/7P5905VoHt3N5Xn2ZWHxcZexDkEiEHV
93oLA7+ahIq5uW3npTz5DP7jPzbe21l5AwnDPGM6adI/uC7nh+1y/+rKTkfswdNHZjRXkCZD
0su09eIGfK6nODri+q9VIF+3OoSzD/3bmZMiHq/i6leTxt1AosXdu9fZavYbNoNfluvfdrPH
EpYvF78t1/vyCY/YmIm1Ot9vdToqyFPY4AYveMAiG4MrBM3GXoZ1gg+wI6UZKBr2wfFobpSE
pR5oBkUjZHj24rOxaVAfCqWkW0MU/ewu83Gd+XwRcvfdMIK5yQvXPQrA7DBQE/nqEoSQRJ6b
lyMCpANs8HDrWFpBrn1bQRSiJuAD38AAafigN17KXoC7g5PwgX2Zb3Ca3noCJLZxPTyqU8Ov
oNCu8Ros+kHwzcvy6hE6/O5Nucais35g76JxNgRvq9GuWDOBo7GFdS7A6+IVN5RAUQauJmbg
oBpQKOClSVojRZYU1O32ttDjsVToSWRgC+6Aou6L7pxlLY0obN3Yo8tJh042N6ePvs/mP6pJ
Evv0ZQvu4IftKC9WJZQ6/cEgmWpp4+bQzoGdPM/dv7wY9zln5u76PIrFtMapuR6F69b3Fh/t
bDaEnfmPnd3Q/PgdhssVV7ey+P2COyFI7eCayLWpppcdLIwUEdW3EneXF9e3bU5m9lMM74An
jrXYNxDtTrjyFBwZNi3FQHoGTKsjtMPASZUZtnJ1tfWWmtk14PPtyDIEOUF8raQuUvVViEzb
/fWmOUwI3tdbrthhb9hBa6StCXnrRFJBCTBhZHQaBHFHaIIFFITn9hVui9SIqZSdv544TtaE
5bfD01Olw3UugQoGJSJLtTd1syQR8Y3hEDvdOUk9B7Rg4ICWqS+FrN4iB38C+9+Su50wg2gH
FN/AGvuu3xB4/EwFB+ZdgaeaZBsRTdLGWOMplbGP7Sagem0vAQiV4+OcakYd+hd37t2Pwywg
lyDZzH8cXioDjmfrp07bILKDSnkGlKrZOs/5EFjEOTg0/DbJiTS5d17vNISVgoKBBchOPeCC
Y6WRs/p7rAqIHSiZG3hcH8F+5FBJj6Vh37t0eIUkRoxlHX2p0itsp53VOXi/g0TN3tP9FqwO
+/JnCT+U+/mnT58+9H2fq0vXVRAc339zrIUYKdAKE9jhG2jHmslGuFOAcZO19ReI1eDshTfc
TybV3t5OCuohajcR9GdgyuBrNUR6kMobV8ZHf1LZ5Vsn5Z7NHL0H/28Y+i23YMs/7mtDVzhU
wVlS/GSvX5zgd0ZO94dfFdkBfi8zEeO/ysUieRluP12612/kONUJwDCrGKD83v/EiYIpJRX4
sD9Zb06xUTdjpePEOed+Y/yMJaX1pzyq02c/Q4eKZLEbJ3xICdpD1PkYyAEsJtzgp2zD7qTy
ESyqCV/FMO/roBw/Dan2YANqgwg+tInc+SKs5sMbssERZFGJFld37zKavVKv+G3kSqGSNDhP
rVTu74NoIjLfOHE+gAjiEJJ9Xo15iyqf/n/RrSH6zTsAAA==

--LQksG6bCIzRHxTLp--

