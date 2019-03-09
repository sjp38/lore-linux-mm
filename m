Return-Path: <SRS0=P3wr=RM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C42DDC10F00
	for <linux-mm@archiver.kernel.org>; Sat,  9 Mar 2019 23:13:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1FF0120815
	for <linux-mm@archiver.kernel.org>; Sat,  9 Mar 2019 23:13:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1FF0120815
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 722918E0003; Sat,  9 Mar 2019 18:13:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D4558E0002; Sat,  9 Mar 2019 18:13:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C54F8E0003; Sat,  9 Mar 2019 18:13:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id F09B48E0002
	for <linux-mm@kvack.org>; Sat,  9 Mar 2019 18:13:33 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 134so1514093pfx.21
        for <linux-mm@kvack.org>; Sat, 09 Mar 2019 15:13:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=PL2++Sk6pvjPcIqOV74sgXvfdRfo48y7fLZmhEfGVw4=;
        b=Tv3KYqxVKsPGYdoat2G2MJoCroTcV4TD2+L7YPHj4vWGEQiwbsVwEK3QbIF3bBrbMA
         WMG33qxwWRjbv9Gh/JnK/NYBTWD9V9iHSDXqCC7wtf7SFfpuoQn8+Sos3RLOq2SOXJEV
         zQB4rVWGBpQaV1p9swJCH6a9XwWZFqOOt5pUO8L4KpPH8d44O/4xawpwcVKZPs2TOj9C
         aEPjyZsERi++cfkbZ78/kIZJqhf5IlNWKrdcC8/gN313CSGGvOE/aoMzMVw8+1//RNfO
         04XgCF/6OPXzikKTKsbe3iJ6mCSSaKh5t2u3nDnHzbsuzgA/hlJSSLxdQthq50k3MRe/
         pVlQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX46llWARAtlCTIVLwMIGgfL8Sat7VnMl+QsDtqj8a+8PUk3zsX
	4uvQ2XDZwISqq0dmGFR8yVO2ImBWjj2ynrxQfIUFxJYBUm8cs0cBBKaUhPOubV7YlOs8n3irF4+
	ipR4YtO37wFjqr/SnLAo86S384bL81gHBWH/0UrNMiIwMXPe88EL2stR7JSAjy8llYQ==
X-Received: by 2002:a63:e206:: with SMTP id q6mr22923138pgh.87.1552173213214;
        Sat, 09 Mar 2019 15:13:33 -0800 (PST)
X-Google-Smtp-Source: APXvYqxjdf0gASW4CVA/fJIEfbQ9yXLQI8Q9aIzc1p8UuXz+3q+w6EsbvUyiofPlDGps85b6KJYa
X-Received: by 2002:a63:e206:: with SMTP id q6mr22923057pgh.87.1552173211474;
        Sat, 09 Mar 2019 15:13:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552173211; cv=none;
        d=google.com; s=arc-20160816;
        b=AiX7akpErhZ3o+vN+jWCIvHqY1nZfIMhtsobdh0bXh4sUPuv6lyL4XejgSUc8k6jsS
         YMEK1nkbaY3nQudymW1A310kCZDXwxvyfvn2jxTpaWbgFs2oPA7dBwNuUJ4WV/cE2oQY
         DaZ4XOYJ8MMlk7YlLL/EuXLwvD7xg3TxraY58sIqGE1qB/v77mEmVLsQy+eYYeicNO8v
         PCO409wNNIRHKia7qRT1tntxP+EDe73/D8BUCzbVLAE0L03KwVqyN69GYpV0u1QMmnNE
         ng0IwV1tnWn7KuY2j4x0UiV7Jp4BGSvxmzQyD0I5XyUP4q9tOFhTH+v2rJB7VS9DjnvL
         Z+hw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=PL2++Sk6pvjPcIqOV74sgXvfdRfo48y7fLZmhEfGVw4=;
        b=JZ74k0gxfv8kUxvTR/TvP/4tuVWwjI8irk+2S5hkv+v2nUOMjWyx4HoDhkY/YX7cyC
         uiCFpJBjfh1sqhKZvdYPzpzqEtCH3LqP8a8GEAkgFvJ9PRIucxtLi6G956F20w1zYA18
         o9FVsKS1u57J0KEphfzf5f89+dv87WkxQlPec8vXGy0/ejrQNCuK9cepuK8pXj9VHXZU
         m8ZdPOVyXtcOeErI7lGqrq0yj19Je8WAm2UIjb2b0jUtYA/S5IBk5uWlyB/XqzWniFmV
         1/MtLSNkgZ+GUAcw4FOB4U93ljMTN7jy/JFqYd+LU+nIZkJkHc0d8kZBFfawDnR1NQkC
         /DYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id o25si1478633pfa.259.2019.03.09.15.13.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Mar 2019 15:13:31 -0800 (PST)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Mar 2019 15:13:30 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,462,1544515200"; 
   d="gz'50?scan'50,208,50";a="121317625"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by orsmga007.jf.intel.com with ESMTP; 09 Mar 2019 15:13:26 -0800
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1h2l9i-0002fp-1e; Sun, 10 Mar 2019 07:13:26 +0800
Date: Sun, 10 Mar 2019 07:12:41 +0800
From: kbuild test robot <lkp@intel.com>
To: Suren Baghdasaryan <surenb@google.com>
Cc: kbuild-all@01.org, gregkh@linuxfoundation.org, tj@kernel.org,
	lizefan@huawei.com, hannes@cmpxchg.org, axboe@kernel.dk,
	dennis@kernel.org, dennisszhou@gmail.com, mingo@redhat.com,
	peterz@infradead.org, akpm@linux-foundation.org, corbet@lwn.net,
	cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@android.com, Suren Baghdasaryan <surenb@google.com>
Subject: Re: [PATCH v5 6/7] refactor header includes to allow kthread.h
 inclusion in psi_types.h
Message-ID: <201903100706.YFmxiZLA%lkp@intel.com>
References: <20190308184311.144521-7-surenb@google.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="IJpNTDwzlM2Ie8A6"
Content-Disposition: inline
In-Reply-To: <20190308184311.144521-7-surenb@google.com>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--IJpNTDwzlM2Ie8A6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Suren,

Thank you for the patch! Yet something to improve:

[auto build test ERROR on linus/master]
[also build test ERROR on v5.0]
[cannot apply to next-20190306]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Suren-Baghdasaryan/psi-pressure-stall-monitors-v5/20190310-024018
config: i386-randconfig-a0-201910 (attached as .config)
compiler: gcc-4.9 (Debian 4.9.4-2) 4.9.4
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

All errors (new ones prefixed by >>):

   drivers/spi/spi-rockchip.c:328:8: error: unknown type name 'irqreturn_t'
    static irqreturn_t rockchip_spi_isr(int irq, void *dev_id)
           ^
   drivers/spi/spi-rockchip.c: In function 'rockchip_spi_isr':
   drivers/spi/spi-rockchip.c:343:9: error: 'IRQ_HANDLED' undeclared (first use in this function)
     return IRQ_HANDLED;
            ^
   drivers/spi/spi-rockchip.c:343:9: note: each undeclared identifier is reported only once for each function it appears in
   drivers/spi/spi-rockchip.c: In function 'rockchip_spi_probe':
>> drivers/spi/spi-rockchip.c:649:2: error: implicit declaration of function 'devm_request_threaded_irq' [-Werror=implicit-function-declaration]
     ret = devm_request_threaded_irq(&pdev->dev, ret, rockchip_spi_isr, NULL,
     ^
   drivers/spi/spi-rockchip.c:650:4: error: 'IRQF_ONESHOT' undeclared (first use in this function)
       IRQF_ONESHOT, dev_name(&pdev->dev), master);
       ^
   cc1: some warnings being treated as errors

vim +/devm_request_threaded_irq +649 drivers/spi/spi-rockchip.c

64e36824b addy ke              2014-07-01  592  
64e36824b addy ke              2014-07-01  593  static int rockchip_spi_probe(struct platform_device *pdev)
64e36824b addy ke              2014-07-01  594  {
43de979dd Jeffy Chen           2017-08-07  595  	int ret;
64e36824b addy ke              2014-07-01  596  	struct rockchip_spi *rs;
64e36824b addy ke              2014-07-01  597  	struct spi_master *master;
64e36824b addy ke              2014-07-01  598  	struct resource *mem;
76b17e6e4 Julius Werner        2015-03-26  599  	u32 rsd_nsecs;
64e36824b addy ke              2014-07-01  600  
64e36824b addy ke              2014-07-01  601  	master = spi_alloc_master(&pdev->dev, sizeof(struct rockchip_spi));
5dcc44ed9 Addy Ke              2014-07-11  602  	if (!master)
64e36824b addy ke              2014-07-01  603  		return -ENOMEM;
5dcc44ed9 Addy Ke              2014-07-11  604  
64e36824b addy ke              2014-07-01  605  	platform_set_drvdata(pdev, master);
64e36824b addy ke              2014-07-01  606  
64e36824b addy ke              2014-07-01  607  	rs = spi_master_get_devdata(master);
64e36824b addy ke              2014-07-01  608  
64e36824b addy ke              2014-07-01  609  	/* Get basic io resource and map it */
64e36824b addy ke              2014-07-01  610  	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
64e36824b addy ke              2014-07-01  611  	rs->regs = devm_ioremap_resource(&pdev->dev, mem);
64e36824b addy ke              2014-07-01  612  	if (IS_ERR(rs->regs)) {
64e36824b addy ke              2014-07-01  613  		ret =  PTR_ERR(rs->regs);
c351587e2 Jeffy Chen           2017-06-13  614  		goto err_put_master;
64e36824b addy ke              2014-07-01  615  	}
64e36824b addy ke              2014-07-01  616  
64e36824b addy ke              2014-07-01  617  	rs->apb_pclk = devm_clk_get(&pdev->dev, "apb_pclk");
64e36824b addy ke              2014-07-01  618  	if (IS_ERR(rs->apb_pclk)) {
64e36824b addy ke              2014-07-01  619  		dev_err(&pdev->dev, "Failed to get apb_pclk\n");
64e36824b addy ke              2014-07-01  620  		ret = PTR_ERR(rs->apb_pclk);
c351587e2 Jeffy Chen           2017-06-13  621  		goto err_put_master;
64e36824b addy ke              2014-07-01  622  	}
64e36824b addy ke              2014-07-01  623  
64e36824b addy ke              2014-07-01  624  	rs->spiclk = devm_clk_get(&pdev->dev, "spiclk");
64e36824b addy ke              2014-07-01  625  	if (IS_ERR(rs->spiclk)) {
64e36824b addy ke              2014-07-01  626  		dev_err(&pdev->dev, "Failed to get spi_pclk\n");
64e36824b addy ke              2014-07-01  627  		ret = PTR_ERR(rs->spiclk);
c351587e2 Jeffy Chen           2017-06-13  628  		goto err_put_master;
64e36824b addy ke              2014-07-01  629  	}
64e36824b addy ke              2014-07-01  630  
64e36824b addy ke              2014-07-01  631  	ret = clk_prepare_enable(rs->apb_pclk);
43de979dd Jeffy Chen           2017-08-07  632  	if (ret < 0) {
64e36824b addy ke              2014-07-01  633  		dev_err(&pdev->dev, "Failed to enable apb_pclk\n");
c351587e2 Jeffy Chen           2017-06-13  634  		goto err_put_master;
64e36824b addy ke              2014-07-01  635  	}
64e36824b addy ke              2014-07-01  636  
64e36824b addy ke              2014-07-01  637  	ret = clk_prepare_enable(rs->spiclk);
43de979dd Jeffy Chen           2017-08-07  638  	if (ret < 0) {
64e36824b addy ke              2014-07-01  639  		dev_err(&pdev->dev, "Failed to enable spi_clk\n");
c351587e2 Jeffy Chen           2017-06-13  640  		goto err_disable_apbclk;
64e36824b addy ke              2014-07-01  641  	}
64e36824b addy ke              2014-07-01  642  
30688e4e6 Emil Renner Berthing 2018-10-31  643  	spi_enable_chip(rs, false);
64e36824b addy ke              2014-07-01  644  
01b59ce5d Emil Renner Berthing 2018-10-31  645  	ret = platform_get_irq(pdev, 0);
01b59ce5d Emil Renner Berthing 2018-10-31  646  	if (ret < 0)
01b59ce5d Emil Renner Berthing 2018-10-31  647  		goto err_disable_spiclk;
01b59ce5d Emil Renner Berthing 2018-10-31  648  
01b59ce5d Emil Renner Berthing 2018-10-31 @649  	ret = devm_request_threaded_irq(&pdev->dev, ret, rockchip_spi_isr, NULL,
01b59ce5d Emil Renner Berthing 2018-10-31  650  			IRQF_ONESHOT, dev_name(&pdev->dev), master);
01b59ce5d Emil Renner Berthing 2018-10-31  651  	if (ret)
01b59ce5d Emil Renner Berthing 2018-10-31  652  		goto err_disable_spiclk;
01b59ce5d Emil Renner Berthing 2018-10-31  653  
64e36824b addy ke              2014-07-01  654  	rs->dev = &pdev->dev;
420b82f84 Emil Renner Berthing 2018-10-31  655  	rs->freq = clk_get_rate(rs->spiclk);
64e36824b addy ke              2014-07-01  656  
76b17e6e4 Julius Werner        2015-03-26  657  	if (!of_property_read_u32(pdev->dev.of_node, "rx-sample-delay-ns",
74b7efa82 Emil Renner Berthing 2018-10-31  658  				  &rsd_nsecs)) {
74b7efa82 Emil Renner Berthing 2018-10-31  659  		/* rx sample delay is expressed in parent clock cycles (max 3) */
74b7efa82 Emil Renner Berthing 2018-10-31  660  		u32 rsd = DIV_ROUND_CLOSEST(rsd_nsecs * (rs->freq >> 8),
74b7efa82 Emil Renner Berthing 2018-10-31  661  				1000000000 >> 8);
74b7efa82 Emil Renner Berthing 2018-10-31  662  		if (!rsd) {
74b7efa82 Emil Renner Berthing 2018-10-31  663  			dev_warn(rs->dev, "%u Hz are too slow to express %u ns delay\n",
74b7efa82 Emil Renner Berthing 2018-10-31  664  					rs->freq, rsd_nsecs);
74b7efa82 Emil Renner Berthing 2018-10-31  665  		} else if (rsd > CR0_RSD_MAX) {
74b7efa82 Emil Renner Berthing 2018-10-31  666  			rsd = CR0_RSD_MAX;
74b7efa82 Emil Renner Berthing 2018-10-31  667  			dev_warn(rs->dev, "%u Hz are too fast to express %u ns delay, clamping at %u ns\n",
74b7efa82 Emil Renner Berthing 2018-10-31  668  					rs->freq, rsd_nsecs,
74b7efa82 Emil Renner Berthing 2018-10-31  669  					CR0_RSD_MAX * 1000000000U / rs->freq);
74b7efa82 Emil Renner Berthing 2018-10-31  670  		}
74b7efa82 Emil Renner Berthing 2018-10-31  671  		rs->rsd = rsd;
74b7efa82 Emil Renner Berthing 2018-10-31  672  	}
76b17e6e4 Julius Werner        2015-03-26  673  
64e36824b addy ke              2014-07-01  674  	rs->fifo_len = get_fifo_len(rs);
64e36824b addy ke              2014-07-01  675  	if (!rs->fifo_len) {
64e36824b addy ke              2014-07-01  676  		dev_err(&pdev->dev, "Failed to get fifo length\n");
db7e8d90c Wei Yongjun          2014-07-20  677  		ret = -EINVAL;
c351587e2 Jeffy Chen           2017-06-13  678  		goto err_disable_spiclk;
64e36824b addy ke              2014-07-01  679  	}
64e36824b addy ke              2014-07-01  680  
64e36824b addy ke              2014-07-01  681  	pm_runtime_set_active(&pdev->dev);
64e36824b addy ke              2014-07-01  682  	pm_runtime_enable(&pdev->dev);
64e36824b addy ke              2014-07-01  683  
64e36824b addy ke              2014-07-01  684  	master->auto_runtime_pm = true;
64e36824b addy ke              2014-07-01  685  	master->bus_num = pdev->id;
04290192f Emil Renner Berthing 2018-10-31  686  	master->mode_bits = SPI_CPOL | SPI_CPHA | SPI_LOOP | SPI_LSB_FIRST;
aa099382a Jeffy Chen           2017-06-28  687  	master->num_chipselect = ROCKCHIP_SPI_MAX_CS_NUM;
64e36824b addy ke              2014-07-01  688  	master->dev.of_node = pdev->dev.of_node;
65498c6ae Emil Renner Berthing 2018-10-31  689  	master->bits_per_word_mask = SPI_BPW_MASK(16) | SPI_BPW_MASK(8) | SPI_BPW_MASK(4);
420b82f84 Emil Renner Berthing 2018-10-31  690  	master->min_speed_hz = rs->freq / BAUDR_SCKDV_MAX;
420b82f84 Emil Renner Berthing 2018-10-31  691  	master->max_speed_hz = min(rs->freq / BAUDR_SCKDV_MIN, MAX_SCLK_OUT);
64e36824b addy ke              2014-07-01  692  
64e36824b addy ke              2014-07-01  693  	master->set_cs = rockchip_spi_set_cs;
64e36824b addy ke              2014-07-01  694  	master->transfer_one = rockchip_spi_transfer_one;
5185a81c0 Brian Norris         2016-07-14  695  	master->max_transfer_size = rockchip_spi_max_transfer_size;
2291793cc Andy Shevchenko      2015-02-27  696  	master->handle_err = rockchip_spi_handle_err;
c863795c4 Jeffy Chen           2017-06-28  697  	master->flags = SPI_MASTER_GPIO_SS;
64e36824b addy ke              2014-07-01  698  
eee06a9ee Emil Renner Berthing 2018-10-31  699  	master->dma_tx = dma_request_chan(rs->dev, "tx");
eee06a9ee Emil Renner Berthing 2018-10-31  700  	if (IS_ERR(master->dma_tx)) {
61cadcf46 Shawn Lin            2016-03-09  701  		/* Check tx to see if we need defer probing driver */
eee06a9ee Emil Renner Berthing 2018-10-31  702  		if (PTR_ERR(master->dma_tx) == -EPROBE_DEFER) {
61cadcf46 Shawn Lin            2016-03-09  703  			ret = -EPROBE_DEFER;
c351587e2 Jeffy Chen           2017-06-13  704  			goto err_disable_pm_runtime;
61cadcf46 Shawn Lin            2016-03-09  705  		}
64e36824b addy ke              2014-07-01  706  		dev_warn(rs->dev, "Failed to request TX DMA channel\n");
eee06a9ee Emil Renner Berthing 2018-10-31  707  		master->dma_tx = NULL;
61cadcf46 Shawn Lin            2016-03-09  708  	}
64e36824b addy ke              2014-07-01  709  
eee06a9ee Emil Renner Berthing 2018-10-31  710  	master->dma_rx = dma_request_chan(rs->dev, "rx");
eee06a9ee Emil Renner Berthing 2018-10-31  711  	if (IS_ERR(master->dma_rx)) {
eee06a9ee Emil Renner Berthing 2018-10-31  712  		if (PTR_ERR(master->dma_rx) == -EPROBE_DEFER) {
e4c0e06f9 Shawn Lin            2016-03-31  713  			ret = -EPROBE_DEFER;
5de7ed0c9 Dan Carpenter        2016-05-04  714  			goto err_free_dma_tx;
64e36824b addy ke              2014-07-01  715  		}
64e36824b addy ke              2014-07-01  716  		dev_warn(rs->dev, "Failed to request RX DMA channel\n");
eee06a9ee Emil Renner Berthing 2018-10-31  717  		master->dma_rx = NULL;
64e36824b addy ke              2014-07-01  718  	}
64e36824b addy ke              2014-07-01  719  
eee06a9ee Emil Renner Berthing 2018-10-31  720  	if (master->dma_tx && master->dma_rx) {
eee06a9ee Emil Renner Berthing 2018-10-31  721  		rs->dma_addr_tx = mem->start + ROCKCHIP_SPI_TXDR;
eee06a9ee Emil Renner Berthing 2018-10-31  722  		rs->dma_addr_rx = mem->start + ROCKCHIP_SPI_RXDR;
64e36824b addy ke              2014-07-01  723  		master->can_dma = rockchip_spi_can_dma;
64e36824b addy ke              2014-07-01  724  	}
64e36824b addy ke              2014-07-01  725  
64e36824b addy ke              2014-07-01  726  	ret = devm_spi_register_master(&pdev->dev, master);
43de979dd Jeffy Chen           2017-08-07  727  	if (ret < 0) {
64e36824b addy ke              2014-07-01  728  		dev_err(&pdev->dev, "Failed to register master\n");
c351587e2 Jeffy Chen           2017-06-13  729  		goto err_free_dma_rx;
64e36824b addy ke              2014-07-01  730  	}
64e36824b addy ke              2014-07-01  731  
64e36824b addy ke              2014-07-01  732  	return 0;
64e36824b addy ke              2014-07-01  733  
c351587e2 Jeffy Chen           2017-06-13  734  err_free_dma_rx:
eee06a9ee Emil Renner Berthing 2018-10-31  735  	if (master->dma_rx)
eee06a9ee Emil Renner Berthing 2018-10-31  736  		dma_release_channel(master->dma_rx);
5de7ed0c9 Dan Carpenter        2016-05-04  737  err_free_dma_tx:
eee06a9ee Emil Renner Berthing 2018-10-31  738  	if (master->dma_tx)
eee06a9ee Emil Renner Berthing 2018-10-31  739  		dma_release_channel(master->dma_tx);
c351587e2 Jeffy Chen           2017-06-13  740  err_disable_pm_runtime:
c351587e2 Jeffy Chen           2017-06-13  741  	pm_runtime_disable(&pdev->dev);
c351587e2 Jeffy Chen           2017-06-13  742  err_disable_spiclk:
64e36824b addy ke              2014-07-01  743  	clk_disable_unprepare(rs->spiclk);
c351587e2 Jeffy Chen           2017-06-13  744  err_disable_apbclk:
64e36824b addy ke              2014-07-01  745  	clk_disable_unprepare(rs->apb_pclk);
c351587e2 Jeffy Chen           2017-06-13  746  err_put_master:
64e36824b addy ke              2014-07-01  747  	spi_master_put(master);
64e36824b addy ke              2014-07-01  748  
64e36824b addy ke              2014-07-01  749  	return ret;
64e36824b addy ke              2014-07-01  750  }
64e36824b addy ke              2014-07-01  751  

:::::: The code at line 649 was first introduced by commit
:::::: 01b59ce5dac856323a0c13c1d51d99a819f32efe spi: rockchip: use irq rather than polling

:::::: TO: Emil Renner Berthing <kernel@esmil.dk>
:::::: CC: Mark Brown <broonie@kernel.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--IJpNTDwzlM2Ie8A6
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
c1lH9yrvAQA=

--IJpNTDwzlM2Ie8A6--

