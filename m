Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C2A206B0313
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 16:22:53 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id a7so699634pgn.7
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 13:22:53 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id l20si2430457pgu.76.2017.06.02.13.22.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Jun 2017 13:22:52 -0700 (PDT)
From: "Christopherson, Sean J" <sean.j.christopherson@intel.com>
Subject: RE: [PATCH] mm/memcontrol: exclude @root from checks in
 mem_cgroup_low
Date: Fri, 2 Jun 2017 20:22:50 +0000
Message-ID: <37306EFA9975BE469F115FDE982C075BC6112095@ORSMSX108.amr.corp.intel.com>
References: <1496434412-21005-1-git-send-email-sean.j.christopherson@intel.com>
In-Reply-To: <1496434412-21005-1-git-send-email-sean.j.christopherson@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "mhocko@kernel.org" <mhocko@kernel.org>
Cc: "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "vdavydov.dev@gmail.com" <vdavydov.dev@gmail.com>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Christopherson, Sean J <sean.j.christopherson@intel.com> wrote:
> Make @root exclusive in mem_cgroup_low; it is never considered low
> when looked at directly and is not checked when traversing the tree.
> In effect, @root is handled identically to how root_mem_cgroup was
> previously handled by mem_cgroup_low.
>=20
> If @root is not excluded from the checks, a cgroup underneath @root
> will never be considered low during targeted reclaim of @root, e.g.
> due to memory.current > memory.high, unless @root is misconfigured
> to have memory.low > memory.high.
>=20
> Excluding @root enables using memory.low to prioritize memory usage
> between cgroups within a subtree of the hierarchy that is limited by
> memory.high or memory.max, e.g. when ROOT owns @root's controls but
> delegates the @root directory to a USER so that USER can create and
> administer children of @root.
>=20
> For example, given cgroup A with children B and C:
>=20
>     A
>    / \
>   B   C
>=20
> and
>=20
>   1. A/memory.current > A/memory.high
>   2. A/B/memory.current < A/B/memory.low
>   3. A/C/memory.current >=3D A/C/memory.low
>=20
> As 'A' is high, i.e. triggers reclaim from 'A', and 'B' is low, we
> should reclaim from 'C' until 'A' is no longer high or until we can
> no longer reclaim from 'C'.  If 'A', i.e. @root, isn't excluded by
> mem_cgroup_low when reclaming from 'A', then 'B' won't be considered
> low and we will reclaim indiscriminately from both 'B' and 'C'.
>=20
> Signed-off-by: Sean Christopherson <sean.j.christopherson@intel.com>

Here is the test I used to confirm the bug and the patch.

20:00:55@sjchrist-vm ? ~ $ cat ~/.bin/memcg_low_test
#!/bin/bash

x62mb=3D$((62<<20))
x66mb=3D$((66<<20))
x94mb=3D$((94<<20))
x98mb=3D$((98<<20))

setup() {
    set -e

    if [[ -n $DEBUG ]]; then
        set -x
    fi

    trap teardown EXIT HUP INT TERM

    if [[ ! -e /mnt/1gb.swap ]]; then
        sudo fallocate -l 1G /mnt/1gb.swap > /dev/null
        sudo mkswap /mnt/1gb.swap > /dev/null
    fi
    if ! swapon --show=3DNAME | grep -q "/mnt/1gb.swap"; then
        sudo swapon /mnt/1gb.swap
    fi

    if [[ ! -e /cgroup/cgroup.controllers ]]; then
        sudo mount -t cgroup2 none /cgroup
    fi

    grep -q memory /cgroup/cgroup.controllers

    sudo sh -c "echo '+memory' > /cgroup/cgroup.subtree_control"

    sudo mkdir /cgroup/A && sudo chown $USER:$USER /cgroup/A
    sudo sh -c "echo '+memory' > /cgroup/A/cgroup.subtree_control"
    sudo sh -c "echo '96m' > /cgroup/A/memory.high"

    mkdir /cgroup/A/0
    mkdir /cgroup/A/1

    echo 64m > /cgroup/A/0/memory.low
}

teardown() {
    set +e

    trap - EXIT HUP INT TERM

    if [[ -z $1 ]]; then
        printf "\n"
        printf "%0.s*" {1..35}
        printf "\nFAILED!\n\n"
        tail /cgroup/A/**/memory.current
        printf "%0.s*" {1..35}
        printf "\n\n"
    fi

    ps | grep stress | tr -s ' ' | cut -f 2 -d ' ' | xargs -I % kill %

    sleep 2

    if [[ -e /cgroup/A/0 ]]; then
        rmdir /cgroup/A/0
    fi
    if [[ -e /cgroup/A/1 ]]; then
        rmdir /cgroup/A/1
    fi
    if [[ -e /cgroup/A ]]; then
        sudo rmdir /cgroup/A
    fi
}


stress_test() {
    sudo sh -c "echo $$ > /cgroup/A/$1/cgroup.procs"
    stress --vm 1 --vm-bytes 64M --vm-keep > /dev/null &

    sudo sh -c "echo $$ > /cgroup/A/$2/cgroup.procs"
    stress --vm 1 --vm-bytes 64M --vm-keep > /dev/null &

    sudo sh -c "echo $$ > /cgroup/cgroup.procs"

    sleep 1

    # A/0 should be consuming more memory than A/1
    [[ $(cat /cgroup/A/0/memory.current) -ge $(cat /cgroup/A/1/memory.curre=
nt) ]]

    # A/0 should be consuming ~64mb
    [[ $(cat /cgroup/A/0/memory.current) -ge $x62mb ]] && [[ $(cat /cgroup/=
A/0/memory.current) -le $x66mb ]]

    # A should cumulatively be consuming ~96mb
    [[ $(cat /cgroup/A/memory.current) -ge $x94mb ]] && [[ $(cat /cgroup/A/=
memory.current) -le $x98mb ]]

    # Stop the stressors
    ps | grep stress | tr -s ' ' | cut -f 2 -d ' ' | xargs -I % kill %
}


teardown 1
setup

for ((i=3D1;i<=3D$1;i++)); do
    printf "ITERATION $i of $1 - stress_test 0 1"
    stress_test 0 1
    printf "\x1b[2K\r"

    printf "ITERATION $i of $1 - stress_test 1 0"
    stress_test 1 0
    printf "\x1b[2K\r"

    printf "ITERATION $i of $1 - PASSED\n"
done

teardown 1


echo PASSED!


20:11:26@sjchrist-vm ? ~ $ memcg_low_test 10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
