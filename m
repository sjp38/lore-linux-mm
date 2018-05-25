Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1B0CB6B0007
	for <linux-mm@kvack.org>; Fri, 25 May 2018 10:08:28 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 89-v6so3149572plc.1
        for <linux-mm@kvack.org>; Fri, 25 May 2018 07:08:28 -0700 (PDT)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0047.outbound.protection.outlook.com. [104.47.32.47])
        by mx.google.com with ESMTPS id u8-v6si23421963plh.22.2018.05.25.07.08.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 May 2018 07:08:25 -0700 (PDT)
From: Bharat Kumar Gogada <bharatku@xilinx.com>
Subject: RE: [PATCH v2 39/40] iommu/arm-smmu-v3: Add support for PRI
Date: Fri, 25 May 2018 14:08:11 +0000
Message-ID: <BLUPR0201MB150513BBAA161355DE9B3A48A5690@BLUPR0201MB1505.namprd02.prod.outlook.com>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-40-jean-philippe.brucker@arm.com>
In-Reply-To: <20180511190641.23008-40-jean-philippe.brucker@arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "joro@8bytes.org" <joro@8bytes.org>, "will.deacon@arm.com" <will.deacon@arm.com>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "alex.williamson@redhat.com" <alex.williamson@redhat.com>, "tn@semihalf.com" <tn@semihalf.com>, "liubo95@huawei.com" <liubo95@huawei.com>, "thunder.leizhen@huawei.com" <thunder.leizhen@huawei.com>, "xieyisheng1@huawei.com" <xieyisheng1@huawei.com>, "xuzaibo@huawei.com" <xuzaibo@huawei.com>, "ilias.apalodimas@linaro.org" <ilias.apalodimas@linaro.org>, "jonathan.cameron@huawei.com" <jonathan.cameron@huawei.com>, "liudongdong3@huawei.com" <liudongdong3@huawei.com>, "shunyong.yang@hxt-semitech.com" <shunyong.yang@hxt-semitech.com>, "nwatters@codeaurora.org" <nwatters@codeaurora.org>, "okaya@codeaurora.org" <okaya@codeaurora.org>, "jcrouse@codeaurora.org" <jcrouse@codeaurora.org>, "rfranz@cavium.com" <rfranz@cavium.com>, "dwmw2@infradead.org" <dwmw2@infradead.org>, "jacob.jun.pan@linux.intel.com" <jacob.jun.pan@linux.intel.com>, "yi.l.liu@intel.com" <yi.l.liu@intel.com>, "ashok.raj@intel.com" <ashok.raj@intel.com>, "kevin.tian@intel.com" <kevin.tian@intel.com>, "baolu.lu@linux.intel.com" <baolu.lu@linux.intel.com>, "robdclark@gmail.com" <robdclark@gmail.com>, "christian.koenig@amd.com" <christian.koenig@amd.com>, Ravikiran Gummaluri <rgummal@xilinx.com>

>=20
> For PCI devices that support it, enable the PRI capability and handle PRI=
 Page
> Requests with the generic fault handler. It is enabled on demand by
> iommu_sva_device_init().
>=20
> Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
>=20
> ---
> v1->v2:
> * Terminate the page request and disable PRI if no handler is registered
> * Enable and disable PRI in sva_device_init/shutdown, instead of
>   add/remove_device
> ---
>  drivers/iommu/arm-smmu-v3.c | 192 +++++++++++++++++++++++++++-------
> --
>  1 file changed, 145 insertions(+), 47 deletions(-)
>=20
> diff --git a/drivers/iommu/arm-smmu-v3.c b/drivers/iommu/arm-smmu-v3.c
> index 6cb69ace371b..0edbb8d19579 100644
> --- a/drivers/iommu/arm-smmu-v3.c
> +++ b/drivers/iommu/arm-smmu-v3.c
> @@ -248,6 +248,7 @@
>  #define STRTAB_STE_1_S1COR		GENMASK_ULL(5, 4)
>  #define STRTAB_STE_1_S1CSH		GENMASK_ULL(7, 6)
>=20
> +#define STRTAB_STE_1_PPAR		(1UL << 18)
>  #define STRTAB_STE_1_S1STALLD		(1UL << 27)
>=20
>  #define STRTAB_STE_1_EATS		GENMASK_ULL(29, 28)
> @@ -309,6 +310,9 @@
>  #define CMDQ_PRI_0_SID			GENMASK_ULL(63, 32)
>  #define CMDQ_PRI_1_GRPID		GENMASK_ULL(8, 0)
>  #define CMDQ_PRI_1_RESP			GENMASK_ULL(13, 12)
> +#define CMDQ_PRI_1_RESP_FAILURE
> 	FIELD_PREP(CMDQ_PRI_1_RESP, 0UL)
> +#define CMDQ_PRI_1_RESP_INVALID
> 	FIELD_PREP(CMDQ_PRI_1_RESP, 1UL)
> +#define CMDQ_PRI_1_RESP_SUCCESS
> 	FIELD_PREP(CMDQ_PRI_1_RESP, 2UL)
>=20
>  #define CMDQ_RESUME_0_SID		GENMASK_ULL(63, 32)
>  #define CMDQ_RESUME_0_ACTION_RETRY	(1UL << 12)
> @@ -383,12 +387,6 @@ module_param_named(disable_ats_check,
> disable_ats_check, bool, S_IRUGO);
> MODULE_PARM_DESC(disable_ats_check,
>  	"By default, the SMMU checks whether each incoming transaction
> marked as translated is allowed by the stream configuration. This option
> disables the check.");
>=20
> -enum pri_resp {
> -	PRI_RESP_DENY =3D 0,
> -	PRI_RESP_FAIL =3D 1,
> -	PRI_RESP_SUCC =3D 2,
> -};
> -
>  enum arm_smmu_msi_index {
>  	EVTQ_MSI_INDEX,
>  	GERROR_MSI_INDEX,
> @@ -471,7 +469,7 @@ struct arm_smmu_cmdq_ent {
>  			u32			sid;
>  			u32			ssid;
>  			u16			grpid;
> -			enum pri_resp		resp;
> +			enum page_response_code	resp;
>  		} pri;
>=20
>  		#define CMDQ_OP_RESUME		0x44
> @@ -556,6 +554,7 @@ struct arm_smmu_strtab_ent {
>  	struct arm_smmu_s2_cfg		*s2_cfg;
>=20
>  	bool				can_stall;
> +	bool				prg_resp_needs_ssid;
>  };
>=20
>  struct arm_smmu_strtab_cfg {
> @@ -907,14 +906,18 @@ static int arm_smmu_cmdq_build_cmd(u64 *cmd,
> struct arm_smmu_cmdq_ent *ent)
>  		cmd[0] |=3D FIELD_PREP(CMDQ_PRI_0_SID, ent->pri.sid);
>  		cmd[1] |=3D FIELD_PREP(CMDQ_PRI_1_GRPID, ent->pri.grpid);
>  		switch (ent->pri.resp) {
> -		case PRI_RESP_DENY:
> -		case PRI_RESP_FAIL:
> -		case PRI_RESP_SUCC:
> +		case IOMMU_PAGE_RESP_FAILURE:
> +			cmd[1] |=3D CMDQ_PRI_1_RESP_FAILURE;
> +			break;
> +		case IOMMU_PAGE_RESP_INVALID:
> +			cmd[1] |=3D CMDQ_PRI_1_RESP_INVALID;
> +			break;
> +		case IOMMU_PAGE_RESP_SUCCESS:
> +			cmd[1] |=3D CMDQ_PRI_1_RESP_SUCCESS;
>  			break;
>  		default:
>  			return -EINVAL;
>  		}
> -		cmd[1] |=3D FIELD_PREP(CMDQ_PRI_1_RESP, ent->pri.resp);
>  		break;
>  	case CMDQ_OP_RESUME:
>  		cmd[0] |=3D FIELD_PREP(CMDQ_RESUME_0_SID, ent-
> >resume.sid); @@ -1114,8 +1117,15 @@ static int
> arm_smmu_page_response(struct device *dev,
>  		cmd.resume.sid		=3D sid;
>  		cmd.resume.stag		=3D resp->page_req_group_id;
>  		cmd.resume.resp		=3D resp->resp_code;
> +	} else if (master->can_fault) {
> +		cmd.opcode		=3D CMDQ_OP_PRI_RESP;
> +		cmd.substream_valid	=3D resp->pasid_present &&
> +					  master->ste.prg_resp_needs_ssid;
> +		cmd.pri.sid		=3D sid;
> +		cmd.pri.ssid		=3D resp->pasid;
> +		cmd.pri.grpid		=3D resp->page_req_group_id;
> +		cmd.pri.resp		=3D resp->resp_code;
>  	} else {
> -		/* TODO: put PRI response here */
>  		return -ENODEV;
>  	}
>=20
> @@ -1236,6 +1246,9 @@ static void arm_smmu_write_strtab_ent(struct
> arm_smmu_device *smmu, u32 sid,
>  			 FIELD_PREP(STRTAB_STE_1_S1CSH,
> ARM_SMMU_SH_ISH) |
>  			 FIELD_PREP(STRTAB_STE_1_STRW, strw));
>=20
> +		if (ste->prg_resp_needs_ssid)
> +			dst[1] |=3D STRTAB_STE_1_PPAR;
> +
>  		if (smmu->features & ARM_SMMU_FEAT_STALLS &&
>  		   !(smmu->features & ARM_SMMU_FEAT_STALL_FORCE) &&
>  		   !ste->can_stall)
> @@ -1471,39 +1484,54 @@ static irqreturn_t arm_smmu_evtq_thread(int
> irq, void *dev)
>=20
>  static void arm_smmu_handle_ppr(struct arm_smmu_device *smmu, u64
> *evt)  {
> -	u32 sid, ssid;
> -	u16 grpid;
> -	bool ssv, last;
> -
> -	sid =3D FIELD_GET(PRIQ_0_SID, evt[0]);
> -	ssv =3D FIELD_GET(PRIQ_0_SSID_V, evt[0]);
> -	ssid =3D ssv ? FIELD_GET(PRIQ_0_SSID, evt[0]) : 0;
> -	last =3D FIELD_GET(PRIQ_0_PRG_LAST, evt[0]);
> -	grpid =3D FIELD_GET(PRIQ_1_PRG_IDX, evt[1]);
> -
> -	dev_info(smmu->dev, "unexpected PRI request received:\n");
> -	dev_info(smmu->dev,
> -		 "\tsid 0x%08x.0x%05x: [%u%s] %sprivileged %s%s%s access
> at iova 0x%016llx\n",
> -		 sid, ssid, grpid, last ? "L" : "",
> -		 evt[0] & PRIQ_0_PERM_PRIV ? "" : "un",
> -		 evt[0] & PRIQ_0_PERM_READ ? "R" : "",
> -		 evt[0] & PRIQ_0_PERM_WRITE ? "W" : "",
> -		 evt[0] & PRIQ_0_PERM_EXEC ? "X" : "",
> -		 evt[1] & PRIQ_1_ADDR_MASK);
> -
> -	if (last) {
> -		struct arm_smmu_cmdq_ent cmd =3D {
> -			.opcode			=3D
> CMDQ_OP_PRI_RESP,
> -			.substream_valid	=3D ssv,
> -			.pri			=3D {
> -				.sid	=3D sid,
> -				.ssid	=3D ssid,
> -				.grpid	=3D grpid,
> -				.resp	=3D PRI_RESP_DENY,
> -			},
> +	u32 sid =3D FIELD_PREP(PRIQ_0_SID, evt[0]);
> +
> +	struct arm_smmu_master_data *master;
> +	struct iommu_fault_event fault =3D {
> +		.type			=3D IOMMU_FAULT_PAGE_REQ,
> +		.last_req		=3D FIELD_GET(PRIQ_0_PRG_LAST,
> evt[0]),
> +		.pasid_valid		=3D FIELD_GET(PRIQ_0_SSID_V, evt[0]),
> +		.pasid			=3D FIELD_GET(PRIQ_0_SSID, evt[0]),
> +		.page_req_group_id	=3D FIELD_GET(PRIQ_1_PRG_IDX,
> evt[1]),
> +		.addr			=3D evt[1] & PRIQ_1_ADDR_MASK,
> +	};
> +
> +	if (evt[0] & PRIQ_0_PERM_READ)
> +		fault.prot |=3D IOMMU_FAULT_READ;
> +	if (evt[0] & PRIQ_0_PERM_WRITE)
> +		fault.prot |=3D IOMMU_FAULT_WRITE;
> +	if (evt[0] & PRIQ_0_PERM_EXEC)
> +		fault.prot |=3D IOMMU_FAULT_EXEC;
> +	if (evt[0] & PRIQ_0_PERM_PRIV)
> +		fault.prot |=3D IOMMU_FAULT_PRIV;
> +
> +	/* Discard Stop PASID marker, it isn't used */
> +	if (!(fault.prot & (IOMMU_FAULT_READ|IOMMU_FAULT_WRITE)) &&
> +	    fault.last_req)
> +		return;
> +
> +	master =3D arm_smmu_find_master(smmu, sid);
> +	if (WARN_ON(!master))
> +		return;
> +
> +	if (iommu_report_device_fault(master->dev, &fault)) {
> +		/*
> +		 * No handler registered, so subsequent faults won't produce
> +		 * better results. Try to disable PRI.
> +		 */
> +		struct page_response_msg page_response =3D {
> +			.addr			=3D fault.addr,
> +			.pasid			=3D fault.pasid,
> +			.pasid_present		=3D fault.pasid_valid,
> +			.page_req_group_id	=3D fault.page_req_group_id,
> +			.resp_code		=3D
> IOMMU_PAGE_RESP_FAILURE,
>  		};
>=20
> -		arm_smmu_cmdq_issue_cmd(smmu, &cmd);
> +		dev_warn(master->dev,
> +			 "PPR 0x%x:0x%llx 0x%x: nobody cared, disabling
> PRI\n",
> +			 fault.pasid_valid ? fault.pasid : 0, fault.addr,
> +			 fault.prot);
> +		arm_smmu_page_response(master->dev, &page_response);
>  	}
>  }
>=20
> @@ -1529,6 +1557,11 @@ static irqreturn_t arm_smmu_priq_thread(int irq,
> void *dev)
>  		}
>=20
>  		if (queue_sync_prod(q) =3D=3D -EOVERFLOW)
> +			/*
> +			 * TODO: flush pending faults, since the SMMU might
> have
> +			 * auto-responded to the Last request of a pending
> +			 * group
> +			 */
>  			dev_err(smmu->dev, "PRIQ overflow detected --
> requests lost\n");
>  	} while (!queue_empty(q));
>=20
> @@ -1577,7 +1610,8 @@ static int arm_smmu_flush_queues(void *cookie,
> struct device *dev)
>  		master =3D dev->iommu_fwspec->iommu_priv;
>  		if (master->ste.can_stall)
>  			arm_smmu_flush_queue(smmu, &smmu->evtq.q,
> "evtq");
> -		/* TODO: add support for PRI */
> +		else if (master->can_fault)
> +			arm_smmu_flush_queue(smmu, &smmu->priq.q,
> "priq");
>  		return 0;
>  	}
>=20
> @@ -2301,6 +2335,59 @@ arm_smmu_iova_to_phys(struct iommu_domain
> *domain, dma_addr_t iova)
>  	return ops->iova_to_phys(ops, iova);
>  }
>=20
> +static int arm_smmu_enable_pri(struct arm_smmu_master_data *master) {
> +	int ret, pos;
> +	struct pci_dev *pdev;
> +	/*
> +	 * TODO: find a good inflight PPR number. We should divide the PRI
> queue
> +	 * by the number of PRI-capable devices, but it's impossible to know
> +	 * about current and future (hotplugged) devices. So we're at risk of
> +	 * dropping PPRs (and leaking pending requests in the FQ).
> +	 */
> +	size_t max_inflight_pprs =3D 16;
> +	struct arm_smmu_device *smmu =3D master->smmu;
> +
> +	if (!(smmu->features & ARM_SMMU_FEAT_PRI) ||
> !dev_is_pci(master->dev))
> +		return -ENOSYS;
> +
> +	pdev =3D to_pci_dev(master->dev);
> +
> +	ret =3D pci_reset_pri(pdev);
> +	if (ret)
> +		return ret;
> +
> +	ret =3D pci_enable_pri(pdev, max_inflight_pprs);
> +	if (ret) {
> +		dev_err(master->dev, "cannot enable PRI: %d\n", ret);
> +		return ret;
> +	}
> +
> +	master->can_fault =3D true;
> +	master->ste.prg_resp_needs_ssid =3D
> pci_prg_resp_requires_prefix(pdev);

Any reason why this is not cleared in arm_smmu_disable_pri ?

> +
> +	dev_dbg(master->dev, "enabled PRI\n");
> +
> +	return 0;
> +}
> +
> +static void arm_smmu_disable_pri(struct arm_smmu_master_data
> *master) {
> +	struct pci_dev *pdev;
> +
> +	if (!dev_is_pci(master->dev))
> +		return;
> +
> +	pdev =3D to_pci_dev(master->dev);
> +
> +	if (!pdev->pri_enabled)
> +		return;
> +
> +	pci_disable_pri(pdev);
> +	dev_dbg(master->dev, "disabled PRI\n");
> +	master->can_fault =3D false;
> +}
> +
>  static int arm_smmu_sva_init(struct device *dev, struct iommu_sva_param
> *param)  {
>  	int ret;
> @@ -2314,11 +2401,15 @@ static int arm_smmu_sva_init(struct device
> *dev, struct iommu_sva_param *param)
>  		return -EINVAL;
>=20
>  	if (param->features & IOMMU_SVA_FEAT_IOPF) {
> -		if (!master->can_fault)
> -			return -EINVAL;
> +		arm_smmu_enable_pri(master);
> +		if (!master->can_fault) {
> +			ret =3D -ENODEV;
> +			goto err_disable_pri;
> +		}
> +
>  		ret =3D iopf_queue_add_device(master->smmu->iopf_queue,
> dev);
>  		if (ret)
> -			return ret;
> +			goto err_disable_pri;
>  	}
>=20
>  	if (!param->max_pasid)
> @@ -2329,11 +2420,17 @@ static int arm_smmu_sva_init(struct device
> *dev, struct iommu_sva_param *param)
>  	param->max_pasid =3D min(param->max_pasid, (1U << master-
> >ssid_bits) - 1);
>=20
>  	return 0;
> +
> +err_disable_pri:
> +	arm_smmu_disable_pri(master);
> +
> +	return ret;
>  }
>=20
>  static void arm_smmu_sva_shutdown(struct device *dev,
>  				  struct iommu_sva_param *param)
>  {
> +	arm_smmu_disable_pri(dev->iommu_fwspec->iommu_priv);
>  	iopf_queue_remove_device(dev);
>  }
>=20
> @@ -2671,6 +2768,7 @@ static void arm_smmu_remove_device(struct
> device *dev)
>  	iommu_group_remove_device(dev);
>  	arm_smmu_remove_master(smmu, master);
>  	iommu_device_unlink(&smmu->iommu, dev);
> +	arm_smmu_disable_pri(master);
>  	arm_smmu_disable_ats(master);
>  	kfree(master);
>  	iommu_fwspec_free(dev);
> --
> 2.17.0
