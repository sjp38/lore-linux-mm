Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8315C8E0001
	for <linux-mm@kvack.org>; Sat, 15 Dec 2018 14:34:21 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id k128-v6so4629903ybc.3
        for <linux-mm@kvack.org>; Sat, 15 Dec 2018 11:34:21 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id y4si5166608ybm.36.2018.12.15.11.34.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Dec 2018 11:34:19 -0800 (PST)
Date: Sat, 15 Dec 2018 22:33:59 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [mmotm:master 267/302]
 drivers/thermal/intel/int340x_thermal/processor_thermal_device.c:434
 proc_thermal_pci_probe() error: 'proc_priv->soc_dts' dereferencing possible
 ERR_PTR()
Message-ID: <20181215193359.GA19692@kadam>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild@01.org, Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>, Waiman Long <longman@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

Hi Andrew,

First bad commit (maybe != root cause):

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   6d5b029d523e959579667282e713106a29c193d2
commit: c3b969e9bb7f00bd1fd376d28778fae406c991f5 [267/302] linux-next-git-rejects

smatch warnings:
drivers/thermal/intel/int340x_thermal/processor_thermal_device.c:434 proc_thermal_pci_probe() error: 'proc_priv->soc_dts' dereferencing possible ERR_PTR()

git remote add mmotm git://git.cmpxchg.org/linux-mmotm.git
git remote update mmotm
git checkout c3b969e9bb7f00bd1fd376d28778fae406c991f5
vim +434 drivers/thermal/intel/int340x_thermal/processor_thermal_device.c

4d0dd6c1 drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2015-03-02  388  
47c93e6b drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2014-12-09  389  static int  proc_thermal_pci_probe(struct pci_dev *pdev,
47c93e6b drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2014-12-09  390  				   const struct pci_device_id *unused)
47c93e6b drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2014-12-09  391  {
47c93e6b drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2014-12-09  392  	struct proc_thermal_device *proc_priv;
47c93e6b drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2014-12-09  393  	int ret;
47c93e6b drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2014-12-09  394  
47c93e6b drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2014-12-09  395  	if (proc_thermal_emum_mode == PROC_THERMAL_PLATFORM_DEV) {
47c93e6b drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2014-12-09  396  		dev_err(&pdev->dev, "error: enumerated as platform dev\n");
47c93e6b drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2014-12-09  397  		return -ENODEV;
47c93e6b drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2014-12-09  398  	}
47c93e6b drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2014-12-09  399  
47c93e6b drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2014-12-09  400  	ret = pci_enable_device(pdev);
47c93e6b drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2014-12-09  401  	if (ret < 0) {
47c93e6b drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2014-12-09  402  		dev_err(&pdev->dev, "error: could not enable device\n");
47c93e6b drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2014-12-09  403  		return ret;
47c93e6b drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2014-12-09  404  	}
47c93e6b drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2014-12-09  405  
47c93e6b drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2014-12-09  406  	ret = proc_thermal_add(&pdev->dev, &proc_priv);
47c93e6b drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2014-12-09  407  	if (ret) {
47c93e6b drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2014-12-09  408  		pci_disable_device(pdev);
47c93e6b drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2014-12-09  409  		return ret;
47c93e6b drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2014-12-09  410  	}
47c93e6b drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2014-12-09  411  
47c93e6b drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2014-12-09  412  	pci_set_drvdata(pdev, proc_priv);
47c93e6b drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2014-12-09  413  	proc_thermal_emum_mode = PROC_THERMAL_PCI;
47c93e6b drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2014-12-09  414  
4d0dd6c1 drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2015-03-02  415  	if (pdev->device == PCI_DEVICE_ID_PROC_BSW_THERMAL) {
4d0dd6c1 drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2015-03-02  416  		/*
4d0dd6c1 drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2015-03-02  417  		 * Enumerate additional DTS sensors available via IOSF.
4d0dd6c1 drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2015-03-02  418  		 * But we are not treating as a failure condition, if
4d0dd6c1 drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2015-03-02  419  		 * there are no aux DTSs enabled or fails. This driver
4d0dd6c1 drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2015-03-02  420  		 * already exposes sensors, which can be accessed via
4d0dd6c1 drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2015-03-02  421  		 * ACPI/MSR. So we don't want to fail for auxiliary DTSs.
4d0dd6c1 drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2015-03-02  422  		 */
4d0dd6c1 drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2015-03-02  423  		proc_priv->soc_dts = intel_soc_dts_iosf_init(

I guess intel_soc_dts_iosf_init() returns error pointers.

4d0dd6c1 drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2015-03-02  424  					INTEL_SOC_DTS_INTERRUPT_MSI, 2, 0);
4d0dd6c1 drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2015-03-02  425  
4d0dd6c1 drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2015-03-02  426  		if (proc_priv->soc_dts && pdev->irq) {

We check for NULL here.  I don't know if it ever returns NULL or only
error pointers.

4d0dd6c1 drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2015-03-02  427  			ret = pci_enable_msi(pdev);
4d0dd6c1 drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2015-03-02  428  			if (!ret) {
4d0dd6c1 drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2015-03-02  429  				ret = request_threaded_irq(pdev->irq, NULL,
4d0dd6c1 drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2015-03-02  430  						proc_thermal_pci_msi_irq,
4d0dd6c1 drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2015-03-02  431  						IRQF_ONESHOT, "proc_thermal",
4d0dd6c1 drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2015-03-02  432  						pdev);
4d0dd6c1 drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2015-03-02  433  				if (ret) {
4d0dd6c1 drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2015-03-02 @434  					intel_soc_dts_iosf_exit(
4d0dd6c1 drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2015-03-02  435  							proc_priv->soc_dts);

Smatch thinks it gets dereferenced inside the intel_soc_dts_iosf_exit()
function.

4d0dd6c1 drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2015-03-02  436  					pci_disable_msi(pdev);
4d0dd6c1 drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2015-03-02  437  					proc_priv->soc_dts = NULL;
4d0dd6c1 drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2015-03-02  438  				}
4d0dd6c1 drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2015-03-02  439  			}
4d0dd6c1 drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2015-03-02  440  		} else
4d0dd6c1 drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2015-03-02  441  			dev_err(&pdev->dev, "No auxiliary DTSs enabled\n");
4d0dd6c1 drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2015-03-02  442  	}
4d0dd6c1 drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2015-03-02  443  
47c93e6b drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2014-12-09  444  	return 0;
47c93e6b drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2014-12-09  445  }
47c93e6b drivers/thermal/int340x_thermal/processor_thermal_device.c Srinivas Pandruvada 2014-12-09  446  

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
