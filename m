Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BACBC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 02:41:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B5A3921873
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 02:41:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B5A3921873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4CEBC6B0007; Thu, 14 Mar 2019 22:41:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 47B1C6B0008; Thu, 14 Mar 2019 22:41:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 346D56B000A; Thu, 14 Mar 2019 22:41:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C36626B0007
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 22:41:28 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id u8so8591448pfm.6
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 19:41:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition
         :content-transfer-encoding:user-agent;
        bh=BaVqHb7OXjk6kdpy3KIGhzKi1TKVTKi9/Ysx6ptMjdc=;
        b=rgnAP59EF74CzPUQcH+aoSmiPfXx0NAQqRHomJ05a4CzScaWDlS+JAgTTifZiZRvUR
         GRQ5QWNlaLBW3RWFlqQNW/GPJ0Syni95JAEoI7VfgTBYuvoYk0L3gnAMRZKvl1LETMFx
         ff21VWrWvWnihfzPY4CQOMFOp9/ECXr99C9SHd6MHaHpcwhpfO0RiJOk1lFD9hSnjedt
         SEprFbkLWvUA1RKnjGUiLJxNn4BHXA0nQ8fRBTe0D1FQVFAHF00J1XrcqLQE6GqBBrH9
         l8pnN3czrMWbNU14c3HJr8xZdJLiIJ1hrfmIU4dhEonwmF3iNNWCH9BOt2jmylLXjrje
         93Zg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV29MXXcSt82UhQi25Lq8GfKt7zP6GmBStKRA2L2hBABVoIiI4f
	1grn+tYAo/nmbK9zXqDda/5gSJY+sjD5AS/qwMMOzQlJf90VgYDP/E+9mx8KrkOdv4uOgiGXwRz
	0w+UzZZHV3Gfln5mDvtUjLdi0YgnH1mpGUKUaOuq3QevS80AQib5Ngq/Mxrxx/l168w==
X-Received: by 2002:a65:5c02:: with SMTP id u2mr1170189pgr.120.1552617688119;
        Thu, 14 Mar 2019 19:41:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdQ5YH5vyiQPUbOL4BwEM0qhXCIlOxfoaRg8AmCp2MMNmje7lJyAbDT4inFx325Q7XCWVY
X-Received: by 2002:a65:5c02:: with SMTP id u2mr1170017pgr.120.1552617684597;
        Thu, 14 Mar 2019 19:41:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552617684; cv=none;
        d=google.com; s=arc-20160816;
        b=Wxz4YoxUCm90zCKhoqOi6qbxw8nVygqp16kOjD5WxVUhEKdwLf+8lNIUwR84Ba99q7
         1+ZQNfBf1y69MCwojwyGmoobU3z/KfI3JfLy2qjjh22yBydo2Cv3cY2gIqN0h46+a8XR
         GE0xqmSq1PUqQUOPVP70JXZfvU8yyjz/zJw/RD7F4/DGJ2ibH/EVaXo5qhFEvvgIc+bJ
         mpvozOXg7AFinmFulB/b8KJ4C9qZLBxJ1WKiUIVFGHoeMHr9z6Yt7UJBqnOvnDydRoY5
         O5VM54kOzPLw5ZMGvyv34Ag8gGoU7MH6gnFKxyDaRt81vJXMPuC30zBCJ4OoTafBHbCn
         iJvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-transfer-encoding:content-disposition
         :mime-version:message-id:subject:cc:to:from:date;
        bh=BaVqHb7OXjk6kdpy3KIGhzKi1TKVTKi9/Ysx6ptMjdc=;
        b=SVYnRdkgml9VqKWCAmDioEbKI6Uh4XisZcNKAvqYCbFXZW9Jfo82/ZQKnmiP/wD8oa
         PiUFGvzBiENNAKvNosOxju4QLichAC2XOfzmNFRApsWgq7/EI2gFc0Bc50uQNocf4w0b
         8gB5oCScfJUBySmZHK06nIvLyS3OSJ73msL5VTYU3UYK1GMEyIbQvXTXdKlXp13+noMC
         AcR0l6nBR+1hIOXpHJEJAcyNbcrJUjbSrHMUDIgRjGy6XNUI2k7qnVnHXfPUh/30yxiu
         CqYFqO/G4XlO4WIp86PEnVWvI0zFbk11a3tKURq0AC22agIO9yeJ2RxNdMlDqoB1D58m
         2rdg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id e2si641227pgv.511.2019.03.14.19.41.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 19:41:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Mar 2019 19:41:23 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,480,1544515200"; 
   d="gz'50?scan'50,208,50";a="142204074"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by orsmga002.jf.intel.com with ESMTP; 14 Mar 2019 19:41:20 -0700
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1h4cme-000CQA-8q; Fri, 15 Mar 2019 10:41:20 +0800
Date: Fri, 15 Mar 2019 10:41:08 +0800
From: kbuild test robot <lkp@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild-all@01.org, Roman Gushchin <guro@fb.com>,
	Linux Memory Management List <linux-mm@kvack.org>,
	Dave Rodgman <dave.rodgman@arm.com>,
	Johannes Weiner <hannes@cmpxchg.org>
Subject: [rgushchin:release_percpu.3 315/395]
 drivers/scsi/qla2xxx/qla_iocb.c:1141:9: warning: format '%llx' expects
 argument of type 'long long unsigned int', but argument 6 has type
 'dma_addr_t'
Message-ID: <201903151001.pvjsFAwy%lkp@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="oyUTqETQ0mS9luUI"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

tree:   https://github.com/rgushchin/linux.git release_percpu.3
head:   52424723f0e77cb4219324aa1a52b400b1a833c9
commit: 648fe0dc00d4411cc40d6a4557c6d1e734da5e54 [315/395] linux-next-git-rejects
config: i386-randconfig-j3-03132258 (attached as .config)
compiler: gcc-4.9 (Debian 4.9.4-2) 4.9.4
reproduce:
        git checkout 648fe0dc00d4411cc40d6a4557c6d1e734da5e54
        # save the attached .config to linux build tree
        make ARCH=i386 

All warnings (new ones prefixed by >>):

   drivers/scsi/qla2xxx/qla_iocb.c: In function 'qla24xx_walk_and_build_prot_sglist':
>> drivers/scsi/qla2xxx/qla_iocb.c:1141:9: warning: format '%llx' expects argument of type 'long long unsigned int', but argument 6 has type 'dma_addr_t' [-Wformat=]
            __func__, sle_phys, sg->length);
            ^
   drivers/scsi/qla2xxx/qla_iocb.c:1182:8: warning: format '%llx' expects argument of type 'long long unsigned int', but argument 7 has type 'dma_addr_t' [-Wformat=]
           difctx->dif_bundl_len, ldma_needed);
           ^

vim +1141 drivers/scsi/qla2xxx/qla_iocb.c

bad75002 Arun Easi         2010-05-04  1094  
f83adb61 Quinn Tran        2014-04-11  1095  int
bad75002 Arun Easi         2010-05-04  1096  qla24xx_walk_and_build_prot_sglist(struct qla_hw_data *ha, srb_t *sp,
f274553c Andrew Morton     2019-03-06  1097      uint32_t *cur_dsd, uint16_t tot_dsds, struct qla_tgt_cmd *tc)
bad75002 Arun Easi         2010-05-04  1098  {
f274553c Andrew Morton     2019-03-06  1099  	struct dsd_dma *dsd_ptr = NULL, *dif_dsd, *nxt_dsd;
f83adb61 Quinn Tran        2014-04-11  1100  	struct scatterlist *sg, *sgl;
f274553c Andrew Morton     2019-03-06  1101  	struct crc_context *difctx = NULL;
f83adb61 Quinn Tran        2014-04-11  1102  	struct scsi_qla_host *vha;
f274553c Andrew Morton     2019-03-06  1103  	uint dsd_list_len;
f274553c Andrew Morton     2019-03-06  1104  	uint avail_dsds = 0;
f274553c Andrew Morton     2019-03-06  1105  	uint used_dsds = tot_dsds;
f274553c Andrew Morton     2019-03-06  1106  	bool dif_local_dma_alloc = false;
f274553c Andrew Morton     2019-03-06  1107  	bool direction_to_device = false;
f274553c Andrew Morton     2019-03-06  1108  	int i;
bad75002 Arun Easi         2010-05-04  1109  
f83adb61 Quinn Tran        2014-04-11  1110  	if (sp) {
f274553c Andrew Morton     2019-03-06  1111  		struct scsi_cmnd *cmd = GET_CMD_SP(sp);
f83adb61 Quinn Tran        2014-04-11  1112  		sgl = scsi_prot_sglist(cmd);
25ff6af1 Joe Carnuccio     2017-01-19  1113  		vha = sp->vha;
f274553c Andrew Morton     2019-03-06  1114  		difctx = sp->u.scmd.ctx;
f274553c Andrew Morton     2019-03-06  1115  		direction_to_device = cmd->sc_data_direction == DMA_TO_DEVICE;
f274553c Andrew Morton     2019-03-06  1116  		ql_dbg(ql_dbg_tgt + ql_dbg_verbose, vha, 0xe021,
f274553c Andrew Morton     2019-03-06  1117  		  "%s: scsi_cmnd: %p, crc_ctx: %p, sp: %p\n",
f274553c Andrew Morton     2019-03-06  1118  			__func__, cmd, difctx, sp);
f83adb61 Quinn Tran        2014-04-11  1119  	} else if (tc) {
f83adb61 Quinn Tran        2014-04-11  1120  		vha = tc->vha;
f83adb61 Quinn Tran        2014-04-11  1121  		sgl = tc->prot_sg;
f274553c Andrew Morton     2019-03-06  1122  		difctx = tc->ctx;
f274553c Andrew Morton     2019-03-06  1123  		direction_to_device = tc->dma_data_direction == DMA_TO_DEVICE;
f83adb61 Quinn Tran        2014-04-11  1124  	} else {
f83adb61 Quinn Tran        2014-04-11  1125  		BUG();
f83adb61 Quinn Tran        2014-04-11  1126  		return 1;
f83adb61 Quinn Tran        2014-04-11  1127  	}
f83adb61 Quinn Tran        2014-04-11  1128  
f274553c Andrew Morton     2019-03-06  1129  	ql_dbg(ql_dbg_tgt + ql_dbg_verbose, vha, 0xe021,
f274553c Andrew Morton     2019-03-06  1130  	    "%s: enter (write=%u)\n", __func__, direction_to_device);
f83adb61 Quinn Tran        2014-04-11  1131  
f274553c Andrew Morton     2019-03-06  1132  	/* if initiator doing write or target doing read */
f274553c Andrew Morton     2019-03-06  1133  	if (direction_to_device) {
f83adb61 Quinn Tran        2014-04-11  1134  		for_each_sg(sgl, sg, tot_dsds, i) {
f274553c Andrew Morton     2019-03-06  1135  			dma_addr_t sle_phys = sg_phys(sg);
f274553c Andrew Morton     2019-03-06  1136  
f274553c Andrew Morton     2019-03-06  1137  			/* If SGE addr + len flips bits in upper 32-bits */
f274553c Andrew Morton     2019-03-06  1138  			if (MSD(sle_phys + sg->length) ^ MSD(sle_phys)) {
f274553c Andrew Morton     2019-03-06  1139  				ql_dbg(ql_dbg_tgt + ql_dbg_verbose, vha, 0xe022,
f274553c Andrew Morton     2019-03-06  1140  				    "%s: page boundary crossing (phys=%llx len=%x)\n",
f274553c Andrew Morton     2019-03-06 @1141  				    __func__, sle_phys, sg->length);
f274553c Andrew Morton     2019-03-06  1142  
f274553c Andrew Morton     2019-03-06  1143  				if (difctx) {
f274553c Andrew Morton     2019-03-06  1144  					ha->dif_bundle_crossed_pages++;
f274553c Andrew Morton     2019-03-06  1145  					dif_local_dma_alloc = true;
f274553c Andrew Morton     2019-03-06  1146  				} else {
f274553c Andrew Morton     2019-03-06  1147  					ql_dbg(ql_dbg_tgt + ql_dbg_verbose,
f274553c Andrew Morton     2019-03-06  1148  					    vha, 0xe022,
f274553c Andrew Morton     2019-03-06  1149  					    "%s: difctx pointer is NULL\n",
f274553c Andrew Morton     2019-03-06  1150  					    __func__);
f274553c Andrew Morton     2019-03-06  1151  				}
f274553c Andrew Morton     2019-03-06  1152  				break;
f274553c Andrew Morton     2019-03-06  1153  			}
f274553c Andrew Morton     2019-03-06  1154  		}
f274553c Andrew Morton     2019-03-06  1155  		ha->dif_bundle_writes++;
f274553c Andrew Morton     2019-03-06  1156  	} else {
f274553c Andrew Morton     2019-03-06  1157  		ha->dif_bundle_reads++;
f274553c Andrew Morton     2019-03-06  1158  	}
f274553c Andrew Morton     2019-03-06  1159  
f274553c Andrew Morton     2019-03-06  1160  	if (ql2xdifbundlinginternalbuffers)
f274553c Andrew Morton     2019-03-06  1161  		dif_local_dma_alloc = direction_to_device;
f274553c Andrew Morton     2019-03-06  1162  
f274553c Andrew Morton     2019-03-06  1163  	if (dif_local_dma_alloc) {
f274553c Andrew Morton     2019-03-06  1164  		u32 track_difbundl_buf = 0;
f274553c Andrew Morton     2019-03-06  1165  		u32 ldma_sg_len = 0;
f274553c Andrew Morton     2019-03-06  1166  		u8 ldma_needed = 1;
f274553c Andrew Morton     2019-03-06  1167  
f274553c Andrew Morton     2019-03-06  1168  		difctx->no_dif_bundl = 0;
f274553c Andrew Morton     2019-03-06  1169  		difctx->dif_bundl_len = 0;
f274553c Andrew Morton     2019-03-06  1170  
f274553c Andrew Morton     2019-03-06  1171  		/* Track DSD buffers */
f274553c Andrew Morton     2019-03-06  1172  		INIT_LIST_HEAD(&difctx->ldif_dsd_list);
f274553c Andrew Morton     2019-03-06  1173  		/* Track local DMA buffers */
f274553c Andrew Morton     2019-03-06  1174  		INIT_LIST_HEAD(&difctx->ldif_dma_hndl_list);
f274553c Andrew Morton     2019-03-06  1175  
f274553c Andrew Morton     2019-03-06  1176  		for_each_sg(sgl, sg, tot_dsds, i) {
f274553c Andrew Morton     2019-03-06  1177  			u32 sglen = sg_dma_len(sg);
f274553c Andrew Morton     2019-03-06  1178  
f274553c Andrew Morton     2019-03-06  1179  			ql_dbg(ql_dbg_tgt + ql_dbg_verbose, vha, 0xe023,
f274553c Andrew Morton     2019-03-06  1180  			    "%s: sg[%x] (phys=%llx sglen=%x) ldma_sg_len: %x dif_bundl_len: %x ldma_needed: %x\n",
f274553c Andrew Morton     2019-03-06  1181  			    __func__, i, sg_phys(sg), sglen, ldma_sg_len,
f274553c Andrew Morton     2019-03-06  1182  			    difctx->dif_bundl_len, ldma_needed);
f274553c Andrew Morton     2019-03-06  1183  
f274553c Andrew Morton     2019-03-06  1184  			while (sglen) {
f274553c Andrew Morton     2019-03-06  1185  				u32 xfrlen = 0;
f274553c Andrew Morton     2019-03-06  1186  
f274553c Andrew Morton     2019-03-06  1187  				if (ldma_needed) {
f274553c Andrew Morton     2019-03-06  1188  					/*
f274553c Andrew Morton     2019-03-06  1189  					 * Allocate list item to store
f274553c Andrew Morton     2019-03-06  1190  					 * the DMA buffers
f274553c Andrew Morton     2019-03-06  1191  					 */
f274553c Andrew Morton     2019-03-06  1192  					dsd_ptr = kzalloc(sizeof(*dsd_ptr),
f274553c Andrew Morton     2019-03-06  1193  					    GFP_ATOMIC);
f274553c Andrew Morton     2019-03-06  1194  					if (!dsd_ptr) {
f274553c Andrew Morton     2019-03-06  1195  						ql_dbg(ql_dbg_tgt, vha, 0xe024,
f274553c Andrew Morton     2019-03-06  1196  						    "%s: failed alloc dsd_ptr\n",
f274553c Andrew Morton     2019-03-06  1197  						    __func__);
f274553c Andrew Morton     2019-03-06  1198  						return 1;
f274553c Andrew Morton     2019-03-06  1199  					}
f274553c Andrew Morton     2019-03-06  1200  					ha->dif_bundle_kallocs++;
f274553c Andrew Morton     2019-03-06  1201  
f274553c Andrew Morton     2019-03-06  1202  					/* allocate dma buffer */
f274553c Andrew Morton     2019-03-06  1203  					dsd_ptr->dsd_addr = dma_pool_alloc
f274553c Andrew Morton     2019-03-06  1204  						(ha->dif_bundl_pool, GFP_ATOMIC,
f274553c Andrew Morton     2019-03-06  1205  						 &dsd_ptr->dsd_list_dma);
f274553c Andrew Morton     2019-03-06  1206  					if (!dsd_ptr->dsd_addr) {
f274553c Andrew Morton     2019-03-06  1207  						ql_dbg(ql_dbg_tgt, vha, 0xe024,
f274553c Andrew Morton     2019-03-06  1208  						    "%s: failed alloc ->dsd_ptr\n",
f274553c Andrew Morton     2019-03-06  1209  						    __func__);
f274553c Andrew Morton     2019-03-06  1210  						/*
f274553c Andrew Morton     2019-03-06  1211  						 * need to cleanup only this
f274553c Andrew Morton     2019-03-06  1212  						 * dsd_ptr rest will be done
f274553c Andrew Morton     2019-03-06  1213  						 * by sp_free_dma()
f274553c Andrew Morton     2019-03-06  1214  						 */
f274553c Andrew Morton     2019-03-06  1215  						kfree(dsd_ptr);
f274553c Andrew Morton     2019-03-06  1216  						ha->dif_bundle_kallocs--;
f274553c Andrew Morton     2019-03-06  1217  						return 1;
f274553c Andrew Morton     2019-03-06  1218  					}
f274553c Andrew Morton     2019-03-06  1219  					ha->dif_bundle_dma_allocs++;
f274553c Andrew Morton     2019-03-06  1220  					ldma_needed = 0;
f274553c Andrew Morton     2019-03-06  1221  					difctx->no_dif_bundl++;
f274553c Andrew Morton     2019-03-06  1222  					list_add_tail(&dsd_ptr->list,
f274553c Andrew Morton     2019-03-06  1223  					    &difctx->ldif_dma_hndl_list);
f274553c Andrew Morton     2019-03-06  1224  				}
f274553c Andrew Morton     2019-03-06  1225  
f274553c Andrew Morton     2019-03-06  1226  				/* xfrlen is min of dma pool size and sglen */
f274553c Andrew Morton     2019-03-06  1227  				xfrlen = (sglen >
f274553c Andrew Morton     2019-03-06  1228  				   (DIF_BUNDLING_DMA_POOL_SIZE - ldma_sg_len)) ?
f274553c Andrew Morton     2019-03-06  1229  				    DIF_BUNDLING_DMA_POOL_SIZE - ldma_sg_len :
f274553c Andrew Morton     2019-03-06  1230  				    sglen;
f274553c Andrew Morton     2019-03-06  1231  
f274553c Andrew Morton     2019-03-06  1232  				/* replace with local allocated dma buffer */
f274553c Andrew Morton     2019-03-06  1233  				sg_pcopy_to_buffer(sgl, sg_nents(sgl),
f274553c Andrew Morton     2019-03-06  1234  				    dsd_ptr->dsd_addr + ldma_sg_len, xfrlen,
f274553c Andrew Morton     2019-03-06  1235  				    difctx->dif_bundl_len);
f274553c Andrew Morton     2019-03-06  1236  				difctx->dif_bundl_len += xfrlen;
f274553c Andrew Morton     2019-03-06  1237  				sglen -= xfrlen;
f274553c Andrew Morton     2019-03-06  1238  				ldma_sg_len += xfrlen;
f274553c Andrew Morton     2019-03-06  1239  				if (ldma_sg_len == DIF_BUNDLING_DMA_POOL_SIZE ||
f274553c Andrew Morton     2019-03-06  1240  				    sg_is_last(sg)) {
f274553c Andrew Morton     2019-03-06  1241  					ldma_needed = 1;
f274553c Andrew Morton     2019-03-06  1242  					ldma_sg_len = 0;
f274553c Andrew Morton     2019-03-06  1243  				}
f274553c Andrew Morton     2019-03-06  1244  			}
f274553c Andrew Morton     2019-03-06  1245  		}
f274553c Andrew Morton     2019-03-06  1246  
f274553c Andrew Morton     2019-03-06  1247  		track_difbundl_buf = used_dsds = difctx->no_dif_bundl;
f274553c Andrew Morton     2019-03-06  1248  		ql_dbg(ql_dbg_tgt + ql_dbg_verbose, vha, 0xe025,
f274553c Andrew Morton     2019-03-06  1249  		    "dif_bundl_len=%x, no_dif_bundl=%x track_difbundl_buf: %x\n",
f274553c Andrew Morton     2019-03-06  1250  		    difctx->dif_bundl_len, difctx->no_dif_bundl,
f274553c Andrew Morton     2019-03-06  1251  		    track_difbundl_buf);
f274553c Andrew Morton     2019-03-06  1252  
f274553c Andrew Morton     2019-03-06  1253  		if (sp)
f274553c Andrew Morton     2019-03-06  1254  			sp->flags |= SRB_DIF_BUNDL_DMA_VALID;
f274553c Andrew Morton     2019-03-06  1255  		else
f274553c Andrew Morton     2019-03-06  1256  			tc->prot_flags = DIF_BUNDL_DMA_VALID;
f274553c Andrew Morton     2019-03-06  1257  
f274553c Andrew Morton     2019-03-06  1258  		list_for_each_entry_safe(dif_dsd, nxt_dsd,
f274553c Andrew Morton     2019-03-06  1259  		    &difctx->ldif_dma_hndl_list, list) {
f274553c Andrew Morton     2019-03-06  1260  			u32 sglen = (difctx->dif_bundl_len >
f274553c Andrew Morton     2019-03-06  1261  			    DIF_BUNDLING_DMA_POOL_SIZE) ?
f274553c Andrew Morton     2019-03-06  1262  			    DIF_BUNDLING_DMA_POOL_SIZE : difctx->dif_bundl_len;
f274553c Andrew Morton     2019-03-06  1263  
f274553c Andrew Morton     2019-03-06  1264  			BUG_ON(track_difbundl_buf == 0);
bad75002 Arun Easi         2010-05-04  1265  
bad75002 Arun Easi         2010-05-04  1266  			/* Allocate additional continuation packets? */
bad75002 Arun Easi         2010-05-04  1267  			if (avail_dsds == 0) {
f274553c Andrew Morton     2019-03-06  1268  				ql_dbg(ql_dbg_tgt + ql_dbg_verbose, vha,
f274553c Andrew Morton     2019-03-06  1269  				    0xe024,
f274553c Andrew Morton     2019-03-06  1270  				    "%s: adding continuation iocb's\n",
f274553c Andrew Morton     2019-03-06  1271  				    __func__);
bad75002 Arun Easi         2010-05-04  1272  				avail_dsds = (used_dsds > QLA_DSDS_PER_IOCB) ?
bad75002 Arun Easi         2010-05-04  1273  				    QLA_DSDS_PER_IOCB : used_dsds;
bad75002 Arun Easi         2010-05-04  1274  				dsd_list_len = (avail_dsds + 1) * 12;
bad75002 Arun Easi         2010-05-04  1275  				used_dsds -= avail_dsds;
bad75002 Arun Easi         2010-05-04  1276  
bad75002 Arun Easi         2010-05-04  1277  				/* allocate tracking DS */
f274553c Andrew Morton     2019-03-06  1278  				dsd_ptr = kzalloc(sizeof(*dsd_ptr), GFP_ATOMIC);
f274553c Andrew Morton     2019-03-06  1279  				if (!dsd_ptr) {
f274553c Andrew Morton     2019-03-06  1280  					ql_dbg(ql_dbg_tgt, vha, 0xe026,
f274553c Andrew Morton     2019-03-06  1281  					    "%s: failed alloc dsd_ptr\n",
f274553c Andrew Morton     2019-03-06  1282  					    __func__);
bad75002 Arun Easi         2010-05-04  1283  					return 1;
f274553c Andrew Morton     2019-03-06  1284  				}
f274553c Andrew Morton     2019-03-06  1285  				ha->dif_bundle_kallocs++;
bad75002 Arun Easi         2010-05-04  1286  
f274553c Andrew Morton     2019-03-06  1287  				difctx->no_ldif_dsd++;
bad75002 Arun Easi         2010-05-04  1288  				/* allocate new list */
f274553c Andrew Morton     2019-03-06  1289  				dsd_ptr->dsd_addr =
bad75002 Arun Easi         2010-05-04  1290  				    dma_pool_alloc(ha->dl_dma_pool, GFP_ATOMIC,
bad75002 Arun Easi         2010-05-04  1291  					&dsd_ptr->dsd_list_dma);
f274553c Andrew Morton     2019-03-06  1292  				if (!dsd_ptr->dsd_addr) {
f274553c Andrew Morton     2019-03-06  1293  					ql_dbg(ql_dbg_tgt, vha, 0xe026,
f274553c Andrew Morton     2019-03-06  1294  					    "%s: failed alloc ->dsd_addr\n",
f274553c Andrew Morton     2019-03-06  1295  					    __func__);
bad75002 Arun Easi         2010-05-04  1296  					/*
f274553c Andrew Morton     2019-03-06  1297  					 * need to cleanup only this dsd_ptr
f274553c Andrew Morton     2019-03-06  1298  					 *  rest will be done by sp_free_dma()
bad75002 Arun Easi         2010-05-04  1299  					 */
bad75002 Arun Easi         2010-05-04  1300  					kfree(dsd_ptr);
f274553c Andrew Morton     2019-03-06  1301  					ha->dif_bundle_kallocs--;
bad75002 Arun Easi         2010-05-04  1302  					return 1;
bad75002 Arun Easi         2010-05-04  1303  				}
f274553c Andrew Morton     2019-03-06  1304  				ha->dif_bundle_dma_allocs++;
bad75002 Arun Easi         2010-05-04  1305  
f83adb61 Quinn Tran        2014-04-11  1306  				if (sp) {
bad75002 Arun Easi         2010-05-04  1307  					list_add_tail(&dsd_ptr->list,
f274553c Andrew Morton     2019-03-06  1308  					    &difctx->ldif_dsd_list);
f274553c Andrew Morton     2019-03-06  1309  					sp->flags |= SRB_CRC_CTX_DSD_VALID;
f274553c Andrew Morton     2019-03-06  1310  				} else {
f274553c Andrew Morton     2019-03-06  1311  					list_add_tail(&dsd_ptr->list,
f274553c Andrew Morton     2019-03-06  1312  					    &difctx->ldif_dsd_list);
f274553c Andrew Morton     2019-03-06  1313  					tc->ctx_dsd_alloced = 1;
f274553c Andrew Morton     2019-03-06  1314  				}
f274553c Andrew Morton     2019-03-06  1315  
f274553c Andrew Morton     2019-03-06  1316  				/* add new list to cmd iocb or last list */
f274553c Andrew Morton     2019-03-06  1317  				*cur_dsd++ =
f274553c Andrew Morton     2019-03-06  1318  				    cpu_to_le32(LSD(dsd_ptr->dsd_list_dma));
f274553c Andrew Morton     2019-03-06  1319  				*cur_dsd++ =
f274553c Andrew Morton     2019-03-06  1320  				    cpu_to_le32(MSD(dsd_ptr->dsd_list_dma));
f274553c Andrew Morton     2019-03-06  1321  				*cur_dsd++ = dsd_list_len;
f274553c Andrew Morton     2019-03-06  1322  				cur_dsd = dsd_ptr->dsd_addr;
f274553c Andrew Morton     2019-03-06  1323  			}
f274553c Andrew Morton     2019-03-06  1324  			*cur_dsd++ = cpu_to_le32(LSD(dif_dsd->dsd_list_dma));
f274553c Andrew Morton     2019-03-06  1325  			*cur_dsd++ = cpu_to_le32(MSD(dif_dsd->dsd_list_dma));
f274553c Andrew Morton     2019-03-06  1326  			*cur_dsd++ = cpu_to_le32(sglen);
f274553c Andrew Morton     2019-03-06  1327  			avail_dsds--;
f274553c Andrew Morton     2019-03-06  1328  			difctx->dif_bundl_len -= sglen;
f274553c Andrew Morton     2019-03-06  1329  			track_difbundl_buf--;
f274553c Andrew Morton     2019-03-06  1330  		}
f274553c Andrew Morton     2019-03-06  1331  
f274553c Andrew Morton     2019-03-06  1332  		ql_dbg(ql_dbg_tgt + ql_dbg_verbose, vha, 0xe026,
f274553c Andrew Morton     2019-03-06  1333  		    "%s: no_ldif_dsd:%x, no_dif_bundl:%x\n", __func__,
f274553c Andrew Morton     2019-03-06  1334  			difctx->no_ldif_dsd, difctx->no_dif_bundl);
f274553c Andrew Morton     2019-03-06  1335  	} else {
f274553c Andrew Morton     2019-03-06  1336  		for_each_sg(sgl, sg, tot_dsds, i) {
f274553c Andrew Morton     2019-03-06  1337  			dma_addr_t sle_dma;
f274553c Andrew Morton     2019-03-06  1338  
f274553c Andrew Morton     2019-03-06  1339  			/* Allocate additional continuation packets? */
f274553c Andrew Morton     2019-03-06  1340  			if (avail_dsds == 0) {
f274553c Andrew Morton     2019-03-06  1341  				avail_dsds = (used_dsds > QLA_DSDS_PER_IOCB) ?
f274553c Andrew Morton     2019-03-06  1342  				    QLA_DSDS_PER_IOCB : used_dsds;
f274553c Andrew Morton     2019-03-06  1343  				dsd_list_len = (avail_dsds + 1) * 12;
f274553c Andrew Morton     2019-03-06  1344  				used_dsds -= avail_dsds;
f274553c Andrew Morton     2019-03-06  1345  
f274553c Andrew Morton     2019-03-06  1346  				/* allocate tracking DS */
f274553c Andrew Morton     2019-03-06  1347  				dsd_ptr = kzalloc(sizeof(*dsd_ptr), GFP_ATOMIC);
f274553c Andrew Morton     2019-03-06  1348  				if (!dsd_ptr) {
f274553c Andrew Morton     2019-03-06  1349  					ql_dbg(ql_dbg_tgt + ql_dbg_verbose,
f274553c Andrew Morton     2019-03-06  1350  					    vha, 0xe027,
f274553c Andrew Morton     2019-03-06  1351  					    "%s: failed alloc dsd_dma...\n",
f274553c Andrew Morton     2019-03-06  1352  					    __func__);
f274553c Andrew Morton     2019-03-06  1353  					return 1;
f274553c Andrew Morton     2019-03-06  1354  				}
f274553c Andrew Morton     2019-03-06  1355  
f274553c Andrew Morton     2019-03-06  1356  				/* allocate new list */
f274553c Andrew Morton     2019-03-06  1357  				dsd_ptr->dsd_addr =
f274553c Andrew Morton     2019-03-06  1358  				    dma_pool_alloc(ha->dl_dma_pool, GFP_ATOMIC,
f274553c Andrew Morton     2019-03-06  1359  					&dsd_ptr->dsd_list_dma);
f274553c Andrew Morton     2019-03-06  1360  				if (!dsd_ptr->dsd_addr) {
f274553c Andrew Morton     2019-03-06  1361  					/* need to cleanup only this dsd_ptr */
f274553c Andrew Morton     2019-03-06  1362  					/* rest will be done by sp_free_dma() */
f274553c Andrew Morton     2019-03-06  1363  					kfree(dsd_ptr);
f274553c Andrew Morton     2019-03-06  1364  					return 1;
f274553c Andrew Morton     2019-03-06  1365  				}
bad75002 Arun Easi         2010-05-04  1366  
f274553c Andrew Morton     2019-03-06  1367  				if (sp) {
f274553c Andrew Morton     2019-03-06  1368  					list_add_tail(&dsd_ptr->list,
f274553c Andrew Morton     2019-03-06  1369  					    &difctx->dsd_list);
bad75002 Arun Easi         2010-05-04  1370  					sp->flags |= SRB_CRC_CTX_DSD_VALID;
f83adb61 Quinn Tran        2014-04-11  1371  				} else {
f83adb61 Quinn Tran        2014-04-11  1372  					list_add_tail(&dsd_ptr->list,
f274553c Andrew Morton     2019-03-06  1373  					    &difctx->dsd_list);
f274553c Andrew Morton     2019-03-06  1374  					tc->ctx_dsd_alloced = 1;
f83adb61 Quinn Tran        2014-04-11  1375  				}
bad75002 Arun Easi         2010-05-04  1376  
bad75002 Arun Easi         2010-05-04  1377  				/* add new list to cmd iocb or last list */
f274553c Andrew Morton     2019-03-06  1378  				*cur_dsd++ =
f274553c Andrew Morton     2019-03-06  1379  				    cpu_to_le32(LSD(dsd_ptr->dsd_list_dma));
f274553c Andrew Morton     2019-03-06  1380  				*cur_dsd++ =
f274553c Andrew Morton     2019-03-06  1381  				    cpu_to_le32(MSD(dsd_ptr->dsd_list_dma));
bad75002 Arun Easi         2010-05-04  1382  				*cur_dsd++ = dsd_list_len;
f274553c Andrew Morton     2019-03-06  1383  				cur_dsd = dsd_ptr->dsd_addr;
bad75002 Arun Easi         2010-05-04  1384  			}
bad75002 Arun Easi         2010-05-04  1385  			sle_dma = sg_dma_address(sg);
bad75002 Arun Easi         2010-05-04  1386  			*cur_dsd++ = cpu_to_le32(LSD(sle_dma));
bad75002 Arun Easi         2010-05-04  1387  			*cur_dsd++ = cpu_to_le32(MSD(sle_dma));
bad75002 Arun Easi         2010-05-04  1388  			*cur_dsd++ = cpu_to_le32(sg_dma_len(sg));
bad75002 Arun Easi         2010-05-04  1389  			avail_dsds--;
bad75002 Arun Easi         2010-05-04  1390  		}
f274553c Andrew Morton     2019-03-06  1391  	}
bad75002 Arun Easi         2010-05-04  1392  	/* Null termination */
bad75002 Arun Easi         2010-05-04  1393  	*cur_dsd++ = 0;
bad75002 Arun Easi         2010-05-04  1394  	*cur_dsd++ = 0;
bad75002 Arun Easi         2010-05-04  1395  	*cur_dsd++ = 0;
bad75002 Arun Easi         2010-05-04  1396  	return 0;
bad75002 Arun Easi         2010-05-04  1397  }
bad75002 Arun Easi         2010-05-04  1398  /**
bad75002 Arun Easi         2010-05-04  1399   * qla24xx_build_scsi_crc_2_iocbs() - Build IOCB command utilizing Command
bad75002 Arun Easi         2010-05-04  1400   *							Type 6 IOCB types.
bad75002 Arun Easi         2010-05-04  1401   *
bad75002 Arun Easi         2010-05-04  1402   * @sp: SRB command to process
bad75002 Arun Easi         2010-05-04  1403   * @cmd_pkt: Command type 3 IOCB
bad75002 Arun Easi         2010-05-04  1404   * @tot_dsds: Total number of segments to transfer
807eb907 Bart Van Assche   2018-10-18  1405   * @tot_prot_dsds: Total number of segments with protection information
807eb907 Bart Van Assche   2018-10-18  1406   * @fw_prot_opts: Protection options to be passed to firmware
bad75002 Arun Easi         2010-05-04  1407   */
d7459527 Michael Hernandez 2016-12-12  1408  inline int
bad75002 Arun Easi         2010-05-04  1409  qla24xx_build_scsi_crc_2_iocbs(srb_t *sp, struct cmd_type_crc_2 *cmd_pkt,
bad75002 Arun Easi         2010-05-04  1410      uint16_t tot_dsds, uint16_t tot_prot_dsds, uint16_t fw_prot_opts)
bad75002 Arun Easi         2010-05-04  1411  {
bad75002 Arun Easi         2010-05-04  1412  	uint32_t		*cur_dsd, *fcp_dl;
bad75002 Arun Easi         2010-05-04  1413  	scsi_qla_host_t		*vha;
bad75002 Arun Easi         2010-05-04  1414  	struct scsi_cmnd	*cmd;
8cb2049c Arun Easi         2011-08-16  1415  	uint32_t		total_bytes = 0;
bad75002 Arun Easi         2010-05-04  1416  	uint32_t		data_bytes;
bad75002 Arun Easi         2010-05-04  1417  	uint32_t		dif_bytes;
bad75002 Arun Easi         2010-05-04  1418  	uint8_t			bundling = 1;
bad75002 Arun Easi         2010-05-04  1419  	uint16_t		blk_size;
bad75002 Arun Easi         2010-05-04  1420  	struct crc_context	*crc_ctx_pkt = NULL;
bad75002 Arun Easi         2010-05-04  1421  	struct qla_hw_data	*ha;
bad75002 Arun Easi         2010-05-04  1422  	uint8_t			additional_fcpcdb_len;
bad75002 Arun Easi         2010-05-04  1423  	uint16_t		fcp_cmnd_len;
bad75002 Arun Easi         2010-05-04  1424  	struct fcp_cmnd		*fcp_cmnd;
bad75002 Arun Easi         2010-05-04  1425  	dma_addr_t		crc_ctx_dma;
bad75002 Arun Easi         2010-05-04  1426  
9ba56b95 Giridhar Malavali 2012-02-09  1427  	cmd = GET_CMD_SP(sp);
bad75002 Arun Easi         2010-05-04  1428  
bad75002 Arun Easi         2010-05-04  1429  	/* Update entry type to indicate Command Type CRC_2 IOCB */
ad950360 Bart Van Assche   2015-07-09  1430  	*((uint32_t *)(&cmd_pkt->entry_type)) = cpu_to_le32(COMMAND_TYPE_CRC_2);
bad75002 Arun Easi         2010-05-04  1431  
25ff6af1 Joe Carnuccio     2017-01-19  1432  	vha = sp->vha;
7c3df132 Saurav Kashyap    2011-07-14  1433  	ha = vha->hw;
7c3df132 Saurav Kashyap    2011-07-14  1434  
bad75002 Arun Easi         2010-05-04  1435  	/* No data transfer */
bad75002 Arun Easi         2010-05-04  1436  	data_bytes = scsi_bufflen(cmd);
bad75002 Arun Easi         2010-05-04  1437  	if (!data_bytes || cmd->sc_data_direction == DMA_NONE) {
ad950360 Bart Van Assche   2015-07-09  1438  		cmd_pkt->byte_count = cpu_to_le32(0);
bad75002 Arun Easi         2010-05-04  1439  		return QLA_SUCCESS;
bad75002 Arun Easi         2010-05-04  1440  	}
bad75002 Arun Easi         2010-05-04  1441  
25ff6af1 Joe Carnuccio     2017-01-19  1442  	cmd_pkt->vp_index = sp->vha->vp_idx;
bad75002 Arun Easi         2010-05-04  1443  
bad75002 Arun Easi         2010-05-04  1444  	/* Set transfer direction */
bad75002 Arun Easi         2010-05-04  1445  	if (cmd->sc_data_direction == DMA_TO_DEVICE) {
bad75002 Arun Easi         2010-05-04  1446  		cmd_pkt->control_flags =
ad950360 Bart Van Assche   2015-07-09  1447  		    cpu_to_le16(CF_WRITE_DATA);
bad75002 Arun Easi         2010-05-04  1448  	} else if (cmd->sc_data_direction == DMA_FROM_DEVICE) {
bad75002 Arun Easi         2010-05-04  1449  		cmd_pkt->control_flags =
ad950360 Bart Van Assche   2015-07-09  1450  		    cpu_to_le16(CF_READ_DATA);
bad75002 Arun Easi         2010-05-04  1451  	}
bad75002 Arun Easi         2010-05-04  1452  
9ba56b95 Giridhar Malavali 2012-02-09  1453  	if ((scsi_get_prot_op(cmd) == SCSI_PROT_READ_INSERT) ||
9ba56b95 Giridhar Malavali 2012-02-09  1454  	    (scsi_get_prot_op(cmd) == SCSI_PROT_WRITE_STRIP) ||
9ba56b95 Giridhar Malavali 2012-02-09  1455  	    (scsi_get_prot_op(cmd) == SCSI_PROT_READ_STRIP) ||
9ba56b95 Giridhar Malavali 2012-02-09  1456  	    (scsi_get_prot_op(cmd) == SCSI_PROT_WRITE_INSERT))
bad75002 Arun Easi         2010-05-04  1457  		bundling = 0;
bad75002 Arun Easi         2010-05-04  1458  
bad75002 Arun Easi         2010-05-04  1459  	/* Allocate CRC context from global pool */
9ba56b95 Giridhar Malavali 2012-02-09  1460  	crc_ctx_pkt = sp->u.scmd.ctx =
501017f6 Souptick Joarder  2018-02-15  1461  	    dma_pool_zalloc(ha->dl_dma_pool, GFP_ATOMIC, &crc_ctx_dma);
bad75002 Arun Easi         2010-05-04  1462  
bad75002 Arun Easi         2010-05-04  1463  	if (!crc_ctx_pkt)
bad75002 Arun Easi         2010-05-04  1464  		goto crc_queuing_error;
bad75002 Arun Easi         2010-05-04  1465  
bad75002 Arun Easi         2010-05-04  1466  	crc_ctx_pkt->crc_ctx_dma = crc_ctx_dma;
bad75002 Arun Easi         2010-05-04  1467  
bad75002 Arun Easi         2010-05-04  1468  	sp->flags |= SRB_CRC_CTX_DMA_VALID;
bad75002 Arun Easi         2010-05-04  1469  
bad75002 Arun Easi         2010-05-04  1470  	/* Set handle */
bad75002 Arun Easi         2010-05-04  1471  	crc_ctx_pkt->handle = cmd_pkt->handle;
bad75002 Arun Easi         2010-05-04  1472  
bad75002 Arun Easi         2010-05-04  1473  	INIT_LIST_HEAD(&crc_ctx_pkt->dsd_list);
bad75002 Arun Easi         2010-05-04  1474  
e02587d7 Arun Easi         2011-08-16  1475  	qla24xx_set_t10dif_tags(sp, (struct fw_dif_context *)
bad75002 Arun Easi         2010-05-04  1476  	    &crc_ctx_pkt->ref_tag, tot_prot_dsds);
bad75002 Arun Easi         2010-05-04  1477  
bad75002 Arun Easi         2010-05-04  1478  	cmd_pkt->crc_context_address[0] = cpu_to_le32(LSD(crc_ctx_dma));
bad75002 Arun Easi         2010-05-04  1479  	cmd_pkt->crc_context_address[1] = cpu_to_le32(MSD(crc_ctx_dma));
bad75002 Arun Easi         2010-05-04  1480  	cmd_pkt->crc_context_len = CRC_CONTEXT_LEN_FW;
bad75002 Arun Easi         2010-05-04  1481  
bad75002 Arun Easi         2010-05-04  1482  	/* Determine SCSI command length -- align to 4 byte boundary */
bad75002 Arun Easi         2010-05-04  1483  	if (cmd->cmd_len > 16) {
bad75002 Arun Easi         2010-05-04  1484  		additional_fcpcdb_len = cmd->cmd_len - 16;
bad75002 Arun Easi         2010-05-04  1485  		if ((cmd->cmd_len % 4) != 0) {
bad75002 Arun Easi         2010-05-04  1486  			/* SCSI cmd > 16 bytes must be multiple of 4 */
bad75002 Arun Easi         2010-05-04  1487  			goto crc_queuing_error;
bad75002 Arun Easi         2010-05-04  1488  		}
bad75002 Arun Easi         2010-05-04  1489  		fcp_cmnd_len = 12 + cmd->cmd_len + 4;
bad75002 Arun Easi         2010-05-04  1490  	} else {
bad75002 Arun Easi         2010-05-04  1491  		additional_fcpcdb_len = 0;
bad75002 Arun Easi         2010-05-04  1492  		fcp_cmnd_len = 12 + 16 + 4;
bad75002 Arun Easi         2010-05-04  1493  	}
bad75002 Arun Easi         2010-05-04  1494  
bad75002 Arun Easi         2010-05-04  1495  	fcp_cmnd = &crc_ctx_pkt->fcp_cmnd;
bad75002 Arun Easi         2010-05-04  1496  
bad75002 Arun Easi         2010-05-04  1497  	fcp_cmnd->additional_cdb_len = additional_fcpcdb_len;
bad75002 Arun Easi         2010-05-04  1498  	if (cmd->sc_data_direction == DMA_TO_DEVICE)
bad75002 Arun Easi         2010-05-04  1499  		fcp_cmnd->additional_cdb_len |= 1;
bad75002 Arun Easi         2010-05-04  1500  	else if (cmd->sc_data_direction == DMA_FROM_DEVICE)
bad75002 Arun Easi         2010-05-04  1501  		fcp_cmnd->additional_cdb_len |= 2;
bad75002 Arun Easi         2010-05-04  1502  
9ba56b95 Giridhar Malavali 2012-02-09  1503  	int_to_scsilun(cmd->device->lun, &fcp_cmnd->lun);
bad75002 Arun Easi         2010-05-04  1504  	memcpy(fcp_cmnd->cdb, cmd->cmnd, cmd->cmd_len);
bad75002 Arun Easi         2010-05-04  1505  	cmd_pkt->fcp_cmnd_dseg_len = cpu_to_le16(fcp_cmnd_len);
bad75002 Arun Easi         2010-05-04  1506  	cmd_pkt->fcp_cmnd_dseg_address[0] = cpu_to_le32(
bad75002 Arun Easi         2010-05-04  1507  	    LSD(crc_ctx_dma + CRC_CONTEXT_FCPCMND_OFF));
bad75002 Arun Easi         2010-05-04  1508  	cmd_pkt->fcp_cmnd_dseg_address[1] = cpu_to_le32(
bad75002 Arun Easi         2010-05-04  1509  	    MSD(crc_ctx_dma + CRC_CONTEXT_FCPCMND_OFF));
65155b37 Uwe Kleine-König  2010-06-11  1510  	fcp_cmnd->task_management = 0;
c3ccb1d7 Saurav Kashyap    2013-07-12  1511  	fcp_cmnd->task_attribute = TSK_SIMPLE;
ff2fc42e Andrew Vasquez    2011-02-23  1512  
bad75002 Arun Easi         2010-05-04  1513  	cmd_pkt->fcp_rsp_dseg_len = 0; /* Let response come in status iocb */
bad75002 Arun Easi         2010-05-04  1514  
bad75002 Arun Easi         2010-05-04  1515  	/* Compute dif len and adjust data len to incude protection */
bad75002 Arun Easi         2010-05-04  1516  	dif_bytes = 0;
bad75002 Arun Easi         2010-05-04  1517  	blk_size = cmd->device->sector_size;
bad75002 Arun Easi         2010-05-04  1518  	dif_bytes = (data_bytes / blk_size) * 8;
8cb2049c Arun Easi         2011-08-16  1519  
9ba56b95 Giridhar Malavali 2012-02-09  1520  	switch (scsi_get_prot_op(GET_CMD_SP(sp))) {
8cb2049c Arun Easi         2011-08-16  1521  	case SCSI_PROT_READ_INSERT:
8cb2049c Arun Easi         2011-08-16  1522  	case SCSI_PROT_WRITE_STRIP:
8cb2049c Arun Easi         2011-08-16  1523  	    total_bytes = data_bytes;
8cb2049c Arun Easi         2011-08-16  1524  	    data_bytes += dif_bytes;
8cb2049c Arun Easi         2011-08-16  1525  	    break;
8cb2049c Arun Easi         2011-08-16  1526  
8cb2049c Arun Easi         2011-08-16  1527  	case SCSI_PROT_READ_STRIP:
8cb2049c Arun Easi         2011-08-16  1528  	case SCSI_PROT_WRITE_INSERT:
8cb2049c Arun Easi         2011-08-16  1529  	case SCSI_PROT_READ_PASS:
8cb2049c Arun Easi         2011-08-16  1530  	case SCSI_PROT_WRITE_PASS:
8cb2049c Arun Easi         2011-08-16  1531  	    total_bytes = data_bytes + dif_bytes;
8cb2049c Arun Easi         2011-08-16  1532  	    break;
8cb2049c Arun Easi         2011-08-16  1533  	default:
8cb2049c Arun Easi         2011-08-16  1534  	    BUG();
bad75002 Arun Easi         2010-05-04  1535  	}
bad75002 Arun Easi         2010-05-04  1536  
e02587d7 Arun Easi         2011-08-16  1537  	if (!qla2x00_hba_err_chk_enabled(sp))
bad75002 Arun Easi         2010-05-04  1538  		fw_prot_opts |= 0x10; /* Disable Guard tag checking */
9e522cd8 Arun Easi         2012-08-22  1539  	/* HBA error checking enabled */
9e522cd8 Arun Easi         2012-08-22  1540  	else if (IS_PI_UNINIT_CAPABLE(ha)) {
9e522cd8 Arun Easi         2012-08-22  1541  		if ((scsi_get_prot_type(GET_CMD_SP(sp)) == SCSI_PROT_DIF_TYPE1)
9e522cd8 Arun Easi         2012-08-22  1542  		    || (scsi_get_prot_type(GET_CMD_SP(sp)) ==
9e522cd8 Arun Easi         2012-08-22  1543  			SCSI_PROT_DIF_TYPE2))
9e522cd8 Arun Easi         2012-08-22  1544  			fw_prot_opts |= BIT_10;
9e522cd8 Arun Easi         2012-08-22  1545  		else if (scsi_get_prot_type(GET_CMD_SP(sp)) ==
9e522cd8 Arun Easi         2012-08-22  1546  		    SCSI_PROT_DIF_TYPE3)
9e522cd8 Arun Easi         2012-08-22  1547  			fw_prot_opts |= BIT_11;
9e522cd8 Arun Easi         2012-08-22  1548  	}
bad75002 Arun Easi         2010-05-04  1549  
bad75002 Arun Easi         2010-05-04  1550  	if (!bundling) {
bad75002 Arun Easi         2010-05-04  1551  		cur_dsd = (uint32_t *) &crc_ctx_pkt->u.nobundling.data_address;
bad75002 Arun Easi         2010-05-04  1552  	} else {
bad75002 Arun Easi         2010-05-04  1553  		/*
bad75002 Arun Easi         2010-05-04  1554  		 * Configure Bundling if we need to fetch interlaving
bad75002 Arun Easi         2010-05-04  1555  		 * protection PCI accesses
bad75002 Arun Easi         2010-05-04  1556  		 */
bad75002 Arun Easi         2010-05-04  1557  		fw_prot_opts |= PO_ENABLE_DIF_BUNDLING;
bad75002 Arun Easi         2010-05-04  1558  		crc_ctx_pkt->u.bundling.dif_byte_count = cpu_to_le32(dif_bytes);
bad75002 Arun Easi         2010-05-04  1559  		crc_ctx_pkt->u.bundling.dseg_count = cpu_to_le16(tot_dsds -
bad75002 Arun Easi         2010-05-04  1560  							tot_prot_dsds);
bad75002 Arun Easi         2010-05-04  1561  		cur_dsd = (uint32_t *) &crc_ctx_pkt->u.bundling.data_address;
bad75002 Arun Easi         2010-05-04  1562  	}
bad75002 Arun Easi         2010-05-04  1563  
bad75002 Arun Easi         2010-05-04  1564  	/* Finish the common fields of CRC pkt */
bad75002 Arun Easi         2010-05-04  1565  	crc_ctx_pkt->blk_size = cpu_to_le16(blk_size);
bad75002 Arun Easi         2010-05-04  1566  	crc_ctx_pkt->prot_opts = cpu_to_le16(fw_prot_opts);
bad75002 Arun Easi         2010-05-04  1567  	crc_ctx_pkt->byte_count = cpu_to_le32(data_bytes);
ad950360 Bart Van Assche   2015-07-09  1568  	crc_ctx_pkt->guard_seed = cpu_to_le16(0);
bad75002 Arun Easi         2010-05-04  1569  	/* Fibre channel byte count */
bad75002 Arun Easi         2010-05-04  1570  	cmd_pkt->byte_count = cpu_to_le32(total_bytes);
bad75002 Arun Easi         2010-05-04  1571  	fcp_dl = (uint32_t *)(crc_ctx_pkt->fcp_cmnd.cdb + 16 +
bad75002 Arun Easi         2010-05-04  1572  	    additional_fcpcdb_len);
bad75002 Arun Easi         2010-05-04  1573  	*fcp_dl = htonl(total_bytes);
bad75002 Arun Easi         2010-05-04  1574  
0c470874 Arun Easi         2010-07-23  1575  	if (!data_bytes || cmd->sc_data_direction == DMA_NONE) {
ad950360 Bart Van Assche   2015-07-09  1576  		cmd_pkt->byte_count = cpu_to_le32(0);
0c470874 Arun Easi         2010-07-23  1577  		return QLA_SUCCESS;
0c470874 Arun Easi         2010-07-23  1578  	}
bad75002 Arun Easi         2010-05-04  1579  	/* Walks data segments */
bad75002 Arun Easi         2010-05-04  1580  
ad950360 Bart Van Assche   2015-07-09  1581  	cmd_pkt->control_flags |= cpu_to_le16(CF_DATA_SEG_DESCR_ENABLE);
8cb2049c Arun Easi         2011-08-16  1582  
8cb2049c Arun Easi         2011-08-16  1583  	if (!bundling && tot_prot_dsds) {
8cb2049c Arun Easi         2011-08-16  1584  		if (qla24xx_walk_and_build_sglist_no_difb(ha, sp,
f83adb61 Quinn Tran        2014-04-11  1585  			cur_dsd, tot_dsds, NULL))
8cb2049c Arun Easi         2011-08-16  1586  			goto crc_queuing_error;
8cb2049c Arun Easi         2011-08-16  1587  	} else if (qla24xx_walk_and_build_sglist(ha, sp, cur_dsd,
f83adb61 Quinn Tran        2014-04-11  1588  			(tot_dsds - tot_prot_dsds), NULL))
bad75002 Arun Easi         2010-05-04  1589  		goto crc_queuing_error;
bad75002 Arun Easi         2010-05-04  1590  
bad75002 Arun Easi         2010-05-04  1591  	if (bundling && tot_prot_dsds) {
bad75002 Arun Easi         2010-05-04  1592  		/* Walks dif segments */
ad950360 Bart Van Assche   2015-07-09  1593  		cmd_pkt->control_flags |= cpu_to_le16(CF_DIF_SEG_DESCR_ENABLE);
bad75002 Arun Easi         2010-05-04  1594  		cur_dsd = (uint32_t *) &crc_ctx_pkt->u.bundling.dif_address;
bad75002 Arun Easi         2010-05-04  1595  		if (qla24xx_walk_and_build_prot_sglist(ha, sp, cur_dsd,
f83adb61 Quinn Tran        2014-04-11  1596  				tot_prot_dsds, NULL))
bad75002 Arun Easi         2010-05-04  1597  			goto crc_queuing_error;
bad75002 Arun Easi         2010-05-04  1598  	}
bad75002 Arun Easi         2010-05-04  1599  	return QLA_SUCCESS;
bad75002 Arun Easi         2010-05-04  1600  
bad75002 Arun Easi         2010-05-04  1601  crc_queuing_error:
bad75002 Arun Easi         2010-05-04  1602  	/* Cleanup will be performed by the caller */
bad75002 Arun Easi         2010-05-04  1603  
bad75002 Arun Easi         2010-05-04  1604  	return QLA_FUNCTION_FAILED;
bad75002 Arun Easi         2010-05-04  1605  }
2b6c0cee Andrew Vasquez    2005-07-06  1606  

:::::: The code at line 1141 was first introduced by commit
:::::: f274553c776ebf03d0b03b54a98ae4b58de98ab7 linux-next

:::::: TO: Andrew Morton <akpm@linux-foundation.org>
:::::: CC: Johannes Weiner <hannes@cmpxchg.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--oyUTqETQ0mS9luUI
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--oyUTqETQ0mS9luUI--

