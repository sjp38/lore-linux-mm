Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id E85386B0006
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 10:17:56 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id q5-v6so2249051ith.1
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 07:17:56 -0700 (PDT)
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id j26-v6si1243506jam.96.2018.08.02.07.17.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Aug 2018 07:17:55 -0700 (PDT)
Message-ID: <5B63126A.6000702@huawei.com>
Date: Thu, 2 Aug 2018 22:17:14 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [Question] A novel case happened when using mempool allocate
 memory.
References: <5B61D243.9050608@huawei.com> <20180801153713.GA4039@bombadil.infradead.org> <5B62A30B.9000008@huawei.com> <20180802133134.GA11845@bombadil.infradead.org>
In-Reply-To: <20180802133134.GA11845@bombadil.infradead.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Laura Abbott <labbott@redhat.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, Linux Memory
 Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2018/8/2 21:31, Matthew Wilcox wrote:
> On Thu, Aug 02, 2018 at 02:22:03PM +0800, zhong jiang wrote:
>> On 2018/8/1 23:37, Matthew Wilcox wrote:
>>> Please post the code.
>> when module is loaded. we create the specific mempool. The code flow is as follows.
> I actually meant "post the code you are testing", not "write out some
> pseudocode".
>
> .
>
The source code is as follow about mempool utility.

**
* @brief a??c' c??c+->>a??e!oao?a,? @smio_mem_type_tc??a(R)?a1?e!oao?a,?e?'
*/
static smio_mem_mng_t g_smio_mem[] =
{
{
.name = "MEDIA_INFO",
.min_pool_size = 128,
.item_size = sizeof(smio_media_info_t),
.slab_cache = NULL,
},
{
.name = "DSW_IO_REQ",
.min_pool_size = 1024,
.item_size = sizeof(dsw_io_req_t),
.slab_cache = NULL,
},
{
.name = "DSW_IO_PAGE",
.min_pool_size = 1024,
.item_size = sizeof(dsw_page_t) * DSW_MAX_PAGE_PER_REQ,
.slab_cache = NULL,
},
{
.name = "32_ARRAY",
.min_pool_size = 1024,
.item_size = sizeof(void *) * 32,
.slab_cache = NULL,
},
{
.name = "SCSI_SENSE_BUF",
.min_pool_size = 1024,
.item_size = sizeof(char) * SCSI_SENSE_BUFFERSIZE,
.slab_cache = NULL,
},
};

/**
* @brief c?3e?.ae??ae?(R)c+->>a??a??a-?
*
* @param id c?3e?.e??ae?!a??ID
* @param type c?3e?.a??a-?c??c+->>a??
*
* @return ae??a??e??a??a??a-?a??c??e|?a??a??;a?+-e'JPYe??a??NULL
*/
void *smio_mem_alloc(smio_module_id_t id, smio_mem_type_t type)
{
void *m = NULL;
smio_mem_mng_t *pool_mng = NULL;
SMIO_ASSERT_RETURN(id < SMIO_MOD_ID_BUTT, NULL);
SMIO_ASSERT_RETURN(type < SMIO_MEM_TYPE_BUTT, NULL);

pool_mng = &g_smio_mem[type];

SMIO_LOG_DEBUG("alloc %s, size: %d\n", pool_mng->name, pool_mng->item_size);

m = mempool_alloc(pool_mng->pool, GFP_KERNEL);
if (NULL == m)
{
return NULL;
}

memset(m, 0, pool_mng->item_size);

atomic_inc(&pool_mng->statistics[id]);

return m;
}
EXPORT_SYMBOL(smio_mem_alloc);


/**
* @brief e??ae? 3/4 a??a-?a??
*
* @param id c?3e?.e??c??ae?!a??ID
* @param type a??a-?a??c??c+->>a??
* @param m a??a??c??e|?a??a??
*/
void smio_mem_free(smio_module_id_t id, smio_mem_type_t type, void *m)
{
smio_mem_mng_t *pool_mng = NULL;
SMIO_ASSERT(NULL != m);
SMIO_ASSERT(id < SMIO_MOD_ID_BUTT);
SMIO_ASSERT(type < SMIO_MEM_TYPE_BUTT);

pool_mng = &g_smio_mem[type];

mempool_free(m, pool_mng->pool);

atomic_dec(&pool_mng->statistics[id]);
}
EXPORT_SYMBOL(smio_mem_free);


/**
* @brief a??a>>oc(R)!c??a??a??ae+- 
*
* @param pool_mng a??a-?c+->>a??c(R)!c??c>>?ae??
*
* @return ae??a??e??a??@SMIO_OK;a?+-e'JPYe??a??@SMIO_ERR
*/
static int smio_mem_pool_create(smio_mem_mng_t *pool_mng)
{
int i;
SMIO_ASSERT_RETURN(NULL != pool_mng, SMIO_ERR);

pool_mng->slab_cache = kmem_cache_create(pool_mng->name,
pool_mng->item_size, 0, 0, NULL);

if (SMIO_IS_ERR_OR_NULL(pool_mng->slab_cache))
{
SMIO_LOG_ERR("kmem_cache_create for %s failed\n", pool_mng->name);
return SMIO_ERR;
}
pool_mng->pool = mempool_create(pool_mng->min_pool_size, mempool_alloc_slab,
mempool_free_slab, pool_mng->slab_cache);
if (NULL == pool_mng->pool)
{
SMIO_LOG_ERR("pool create for %s failed\n", pool_mng->name);
kmem_cache_destroy(pool_mng->slab_cache);
return SMIO_ERR;
}

for (i = 0; i < SMIO_MOD_ID_BUTT; i++)
{
atomic_set(&pool_mng->statistics[i], 0);
}

return SMIO_OK;
}


/**
* @brief ae,?e??a??a-?ae+- 
*
* @param pool_mng ae??e|?ae,?e??c??a??a-?ae+- 
*/
void smio_mem_pool_destroy(smio_mem_mng_t *pool_mng)
{
SMIO_ASSERT(NULL != pool_mng);

if (NULL != pool_mng->pool)
{
mempool_destroy(pool_mng->pool);
pool_mng->pool = NULL;
}

if (NULL != pool_mng->slab_cache)
{
kmem_cache_destroy(pool_mng->slab_cache);
pool_mng->slab_cache = NULL;
}
}


/**
* @brief a??a-?c(R)!c??a??a??a??a??a??
*
* @return ae??a??e??a??@SMIO_OK;a?+-e'JPYe??a??@SMIO_ERR
*/
int smio_mem_init(void)
{
int i;
int pool_num = (int) SMIO_ARRAY_SIZE(g_smio_mem);
int ret = SMIO_OK;
bool free = SMIO_FALSE;

for (i = 0; i < pool_num; i++)
{
SMIO_LOG_INFO("memory of %s initialize, min_pool_size: %d, item_size: %d\n",
g_smio_mem[i].name, g_smio_mem[i].min_pool_size, g_smio_mem[i].item_size);
if (SMIO_OK != smio_mem_pool_create(&g_smio_mem[i]))
{
SMIO_LOG_ERR("memory of %s initialize failed\n", g_smio_mem[i].name);
ret = SMIO_ERR;
free = SMIO_TRUE;
break;
}
}

/* clean if smio_mem_pool_create failed*/
while ((SMIO_TRUE == free) && (--i >= 0))
{
smio_mem_pool_destroy(&g_smio_mem[i]);
}

return ret;
}


/**
* @brief a??a-?c(R)!c??ae?!a??ae,?e??e??a?o
*/
void smio_mem_exit(void)
{
int i;
int pool_num = (int) SMIO_ARRAY_SIZE(g_smio_mem);

for (i = 0; i < pool_num; i++)
{
smio_mem_pool_destroy(&g_smio_mem[i]);
}
}
